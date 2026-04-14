from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
import json
from datetime import datetime
from .database import get_db_connection
from .authentication import JWTAuthentication
import uuid

@csrf_exempt
@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def create_late_entry_notification(request):
    """Create a notification for late entry"""
    try:
        data = request.data if hasattr(request, 'data') else json.loads(request.body)
        site_id = data.get('site_id')
        entry_type = data.get('entry_type')
        message = data.get('message')
        actual_time = data.get('actual_time')
        
        if not all([site_id, entry_type, message, actual_time]):
            return Response({
                'error': 'Missing required fields'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Get supervisor info from authenticated user
        supervisor_id = request.user.get('user_id')
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get supervisor name
        cursor.execute("""
            SELECT full_name FROM users WHERE id = %s
        """, (supervisor_id,))
        supervisor_result = cursor.fetchone()
        supervisor_name = supervisor_result[0] if supervisor_result else 'Unknown'
        
        # Get site name
        cursor.execute("""
            SELECT site_name FROM sites WHERE id = %s
        """, (site_id,))
        site_result = cursor.fetchone()
        site_name = site_result[0] if site_result else 'Unknown Site'
        
        # Create notification
        notification_id = str(uuid.uuid4())
        cursor.execute("""
            INSERT INTO notifications (
                id, site_id, entry_type, message, actual_time,
                supervisor_id, supervisor_name, site_name
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id, created_at
        """, (
            notification_id, site_id, entry_type, message, actual_time,
            supervisor_id, supervisor_name, site_name
        ))
        
        result = cursor.fetchone()
        conn.commit()
        
        # Get all admin user IDs for response
        cursor.execute("""
            SELECT id FROM users WHERE role_id = 1
        """)
        admin_ids = [str(row[0]) for row in cursor.fetchall()]
        
        cursor.close()
        conn.close()
        
        return Response({
            'success': True,
            'notification_id': str(result[0]),
            'created_at': result[1].isoformat(),
            'sent_to': admin_ids
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        print(f"Error creating notification: {e}")
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@csrf_exempt
@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_notifications(request):
    """Get all notifications for admin"""
    try:
        # Check if user is admin
        conn = get_db_connection()
        cursor = conn.cursor()
        
        user_id = request.user.get('user_id')
        cursor.execute("""
            SELECT role_id FROM users WHERE id = %s
        """, (user_id,))
        user_role = cursor.fetchone()
        
        # role_id 1 = Admin
        if not user_role or user_role[0] != 1:
            cursor.close()
            conn.close()
            return Response({
                'error': 'Unauthorized. Admin access required.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Get query parameters
        is_read = request.GET.get('is_read')
        limit = int(request.GET.get('limit', 50))
        offset = int(request.GET.get('offset', 0))
        
        # Build query
        query = """
            SELECT 
                n.id, n.site_id, n.entry_type, n.message, n.actual_time,
                n.created_at, n.is_read, n.read_at,
                n.supervisor_id, n.supervisor_name, n.site_name
            FROM notifications n
            WHERE 1=1
        """
        params = []
        
        if is_read is not None:
            query += " AND n.is_read = %s"
            params.append(is_read == 'true')
        
        query += " ORDER BY n.created_at DESC LIMIT %s OFFSET %s"
        params.extend([limit, offset])
        
        cursor.execute(query, params)
        notifications = cursor.fetchall()
        
        # Get total count
        count_query = "SELECT COUNT(*) FROM notifications WHERE 1=1"
        count_params = []
        if is_read is not None:
            count_query += " AND is_read = %s"
            count_params.append(is_read == 'true')
        
        cursor.execute(count_query, count_params)
        total_count = cursor.fetchone()[0]
        
        # Get unread count
        cursor.execute("SELECT COUNT(*) FROM notifications WHERE is_read = FALSE")
        unread_count = cursor.fetchone()[0]
        
        cursor.close()
        conn.close()
        
        notifications_list = []
        for n in notifications:
            notifications_list.append({
                'id': str(n[0]),
                'site_id': str(n[1]),
                'entry_type': n[2],
                'message': n[3],
                'actual_time': n[4].isoformat() if n[4] else None,
                'created_at': n[5].isoformat() if n[5] else None,
                'is_read': n[6],
                'read_at': n[7].isoformat() if n[7] else None,
                'supervisor_id': str(n[8]) if n[8] else None,
                'supervisor_name': n[9],
                'site_name': n[10]
            })
        
        return Response({
            'success': True,
            'notifications': notifications_list,
            'total': total_count,
            'unread_count': unread_count
        })
        
    except Exception as e:
        print(f"Error fetching notifications: {e}")
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@csrf_exempt
@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def mark_notification_read(request, notification_id):
    """Mark a notification as read"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Check if user is admin
        user_id = request.user.get('user_id')
        cursor.execute("""
            SELECT role_id FROM users WHERE id = %s
        """, (user_id,))
        user_role = cursor.fetchone()
        
        # role_id 1 = Admin
        if not user_role or user_role[0] != 1:
            cursor.close()
            conn.close()
            return Response({
                'error': 'Unauthorized. Admin access required.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Mark as read
        cursor.execute("""
            UPDATE notifications
            SET is_read = TRUE, read_at = CURRENT_TIMESTAMP
            WHERE id = %s
            RETURNING id
        """, (notification_id,))
        
        result = cursor.fetchone()
        conn.commit()
        cursor.close()
        conn.close()
        
        if not result:
            return Response({
                'error': 'Notification not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        return Response({
            'success': True,
            'message': 'Notification marked as read'
        })
        
    except Exception as e:
        print(f"Error marking notification as read: {e}")
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@csrf_exempt
@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def mark_all_notifications_read(request):
    """Mark all notifications as read"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Check if user is admin
        user_id = request.user.get('user_id')
        cursor.execute("""
            SELECT role_id FROM users WHERE id = %s
        """, (user_id,))
        user_role = cursor.fetchone()
        
        # role_id 1 = Admin
        if not user_role or user_role[0] != 1:
            cursor.close()
            conn.close()
            return Response({
                'error': 'Unauthorized. Admin access required.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Mark all as read
        cursor.execute("""
            UPDATE notifications
            SET is_read = TRUE, read_at = CURRENT_TIMESTAMP
            WHERE is_read = FALSE
            RETURNING id
        """)
        
        updated_count = cursor.rowcount
        conn.commit()
        cursor.close()
        conn.close()
        
        return Response({
            'success': True,
            'message': f'{updated_count} notifications marked as read'
        })
        
    except Exception as e:
        print(f"Error marking all notifications as read: {e}")
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
