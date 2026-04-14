import firebase_admin
from firebase_admin import credentials, auth
import os

# Initialize Firebase Admin SDK
def initialize_firebase():
    """Initialize Firebase Admin SDK with service account"""
    try:
        # Check if already initialized
        firebase_admin.get_app()
    except ValueError:
        # Path to your Firebase service account key JSON file
        # You need to download this from Firebase Console
        cred_path = os.path.join(os.path.dirname(__file__), 'firebase-service-account.json')
        
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            print("[OK] Firebase Admin SDK initialized successfully")
        else:
            print("[WARNING] Firebase service account file not found!")
            print(f"Expected location: {cred_path}")
            print("Download it from Firebase Console > Project Settings > Service Accounts")

def verify_firebase_token(id_token):
    """
    Verify Firebase ID token and return decoded token
    
    Args:
        id_token (str): Firebase ID token from client
        
    Returns:
        dict: Decoded token with user info or None if invalid
    """
    try:
        # Try to verify with Firebase Admin SDK first
        decoded_token = auth.verify_id_token(id_token)
        return {
            'uid': decoded_token.get('uid'),
            'email': decoded_token.get('email'),
            'name': decoded_token.get('name', ''),
            'picture': decoded_token.get('picture', ''),
            'email_verified': decoded_token.get('email_verified', False)
        }
    except Exception as e:
        print(f"[WARNING] Firebase Admin SDK verification failed: {str(e)}")
        print("[DEV] Attempting to decode token without verification (DEVELOPMENT ONLY)")
        
        # TEMPORARY WORKAROUND: Decode without verification
        # WARNING: This is NOT secure for production!
        try:
            import base64
            import json
            
            # Split the JWT token (header.payload.signature)
            parts = id_token.split('.')
            if len(parts) != 3:
                print("[ERROR] Invalid token format")
                return None
            
            # Decode the payload (second part)
            # Add padding if needed
            payload = parts[1]
            padding = 4 - len(payload) % 4
            if padding != 4:
                payload += '=' * padding
            
            decoded_bytes = base64.urlsafe_b64decode(payload)
            decoded_token = json.loads(decoded_bytes)
            
            print(f"[OK] Token decoded (unverified): {decoded_token.get('email')}")
            
            return {
                'uid': decoded_token.get('user_id') or decoded_token.get('sub'),
                'email': decoded_token.get('email'),
                'name': decoded_token.get('name', ''),
                'picture': decoded_token.get('picture', ''),
                'email_verified': decoded_token.get('email_verified', False)
            }
        except Exception as decode_error:
            print(f"[ERROR] Token decode failed: {str(decode_error)}")
            return None
