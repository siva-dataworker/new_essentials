import jwt
import datetime
from django.conf import settings

# Secret key for JWT (should be in settings.py or .env)
SECRET_KEY = getattr(settings, 'JWT_SECRET_KEY', settings.SECRET_KEY)
ALGORITHM = 'HS256'
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7  # 7 days

def generate_access_token(user_data):
    """
    Generate JWT access token for user
    
    Args:
        user_data (dict): User information to encode in token
        
    Returns:
        str: JWT access token
    """
    payload = {
        'user_id': user_data.get('user_id'),
        'user_uid': user_data.get('user_uid'),
        'username': user_data.get('username'),
        'email': user_data.get('email'),
        'role': user_data.get('role'),
        'exp': datetime.datetime.utcnow() + datetime.timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
        'iat': datetime.datetime.utcnow()
    }
    
    token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
    return token

def decode_access_token(token):
    """
    Decode and verify JWT access token
    
    Args:
        token (str): JWT access token
        
    Returns:
        dict: Decoded token payload or None if invalid
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        print("❌ Token has expired")
        return None
    except jwt.InvalidTokenError as e:
        print(f"❌ Invalid token: {str(e)}")
        return None
