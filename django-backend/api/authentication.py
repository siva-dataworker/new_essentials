from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from .jwt_utils import decode_access_token

class AuthenticatedUser:
    """
    Simple user object wrapper for JWT authentication
    """
    def __init__(self, user_data):
        self.user_data = user_data
        self.is_authenticated = True
    
    def __getitem__(self, key):
        return self.user_data.get(key)
    
    def get(self, key, default=None):
        return self.user_data.get(key, default)

class JWTAuthentication(BaseAuthentication):
    """
    Custom JWT authentication class for Django REST Framework
    """
    
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')
        
        if not auth_header:
            return None
        
        try:
            # Expected format: "Bearer <token>"
            parts = auth_header.split()
            
            if len(parts) != 2 or parts[0].lower() != 'bearer':
                raise AuthenticationFailed('Invalid authorization header format')
            
            token = parts[1]
            payload = decode_access_token(token)
            
            if not payload:
                raise AuthenticationFailed('Invalid or expired token')
            
            # Return user object wrapper
            user = AuthenticatedUser(payload)
            return (user, None)
            
        except Exception as e:
            raise AuthenticationFailed(f'Authentication failed: {str(e)}')
    
    def authenticate_header(self, request):
        return 'Bearer'
