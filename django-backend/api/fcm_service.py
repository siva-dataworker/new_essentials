"""
FCM push notification service.

Uses the firebase-admin SDK (already installed) to send push notifications
to Android/iOS devices registered in the device_tokens table.
"""

import firebase_admin
from firebase_admin import messaging
from .database import get_db_connection


def _ensure_firebase_ready():
    """Return True if Firebase is initialised, False if not."""
    try:
        firebase_admin.get_app()
        return True
    except ValueError:
        print('[FCM] Firebase not initialised — push notifications disabled')
        return False


def send_push_to_admins(title: str, body: str, data: dict = None) -> dict:
    """
    Send a push notification to every admin device token stored in
    the device_tokens table.

    Returns a summary dict: {'sent': N, 'failed': N}
    """
    if not _ensure_firebase_ready():
        return {'sent': 0, 'failed': 0}

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Fetch all FCM tokens belonging to admin users (role_id = 1)
        cursor.execute("""
            SELECT dt.fcm_token
            FROM device_tokens dt
            JOIN users u ON u.id = dt.user_id
            WHERE u.role_id = 1
              AND dt.fcm_token IS NOT NULL
              AND dt.fcm_token <> ''
        """)
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        if not rows:
            print('[FCM] No admin device tokens found')
            return {'sent': 0, 'failed': 0}

        tokens = [row[0] for row in rows]

        message = messaging.MulticastMessage(
            tokens=tokens,
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    channel_id='essential_homes_alerts',
                    sound='default',
                    icon='ic_launcher',
                ),
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(sound='default', badge=1),
                ),
            ),
        )

        response = messaging.send_each_for_multicast(message)
        print(f'[FCM] sent={response.success_count} failed={response.failure_count}')

        # Clean up any invalid tokens that FCM rejected
        if response.failure_count > 0:
            _remove_invalid_tokens(tokens, response.responses)

        return {
            'sent': response.success_count,
            'failed': response.failure_count,
        }

    except Exception as e:
        print(f'[FCM ERROR] send_push_to_admins: {e}')
        return {'sent': 0, 'failed': 0, 'error': str(e)}


def send_push_to_tokens(tokens: list, title: str, body: str, data: dict = None) -> dict:
    """Send a push notification to an explicit list of FCM tokens."""
    if not _ensure_firebase_ready() or not tokens:
        return {'sent': 0, 'failed': 0}

    try:
        message = messaging.MulticastMessage(
            tokens=tokens,
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    channel_id='essential_homes_alerts',
                    sound='default',
                ),
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(sound='default', badge=1),
                ),
            ),
        )

        response = messaging.send_each_for_multicast(message)
        return {
            'sent': response.success_count,
            'failed': response.failure_count,
        }

    except Exception as e:
        print(f'[FCM ERROR] send_push_to_tokens: {e}')
        return {'sent': 0, 'failed': 0, 'error': str(e)}


def _remove_invalid_tokens(tokens: list, responses: list):
    """Delete tokens that FCM rejected (unregistered / invalid)."""
    invalid = [
        tokens[i] for i, r in enumerate(responses)
        if not r.success
        and r.exception
        and 'registration-token-not-registered' in str(r.exception).lower()
    ]
    if not invalid:
        return
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        for token in invalid:
            cursor.execute('DELETE FROM device_tokens WHERE fcm_token = %s', (token,))
        conn.commit()
        cursor.close()
        conn.close()
        print(f'[FCM] removed {len(invalid)} stale token(s)')
    except Exception as e:
        print(f'[FCM] error removing stale tokens: {e}')
