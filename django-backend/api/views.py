from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from backend.firebase_config import verify_firebase_token
from .jwt_utils import generate_access_token
from .database import get_user_by_uid, create_user, update_user_profile, update_user_profile_by_email, get_role_name
from .authentication import JWTAuthentication

@api_view(['POST'])
@permission_classes([AllowAny])
def signin(request):
    """
    API 1: Authentication & Sign-In
    
    POST /api/auth/signin/
    
    Request body:
    {
        "firebase_id_token": "<firebase_id_token>"
    }
    
    Response:
    {
        "is_new_user": true/false,
        "access_token": "<backend_bearer_token>",
        "user": {
            "user_uid": "firebase_uid",
            "email": "user@gmail.com",
            "full_name": "User Name",
            "role": "Supervisor",
            "role_locked": false
        }
    }
    """
    try:
        # Get Firebase ID token from request
        firebase_token = request.data.get('firebase_id_token')
        
        if not firebase_token:
            return Response({
                'error': 'firebase_id_token is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Verify Firebase token
        firebase_user = verify_firebase_token(firebase_token)
        
        if not firebase_user:
            return Response({
                'error': 'Invalid Firebase token'
            }, status=status.HTTP_401_UNAUTHORIZED)
        
        user_uid = firebase_user['uid']
        email = firebase_user['email']
        full_name = firebase_user['name'] or email.split('@')[0]
        
        # Check if user exists in database
        user = get_user_by_uid(user_uid)
        is_new_user = False
        
        if not user:
            # Create new user
            user = create_user(user_uid, email, full_name)
            is_new_user = True
            
            if not user:
                return Response({
                    'error': 'Failed to create user'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        # Generate Django JWT bearer token
        access_token = generate_access_token({
            'user_uid': user['user_uid'],
            'email': user['email']
        })
        
        # Return response
        return Response({
            'is_new_user': is_new_user,
            'access_token': access_token,
            'user': {
                'user_uid': user['user_uid'],
                'email': user['email'],
                'full_name': user['full_name'],
                'phone': user['phone'],
                'role': get_role_name(user['role_id']),
                'role_locked': user['role_locked']
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'error': f'Authentication failed: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_profile(request):
    """
    API 2: Get User Profile
    
    GET /api/user/profile/
    
    Headers:
    Authorization: Bearer <backend_bearer_token>
    
    Response:
    {
        "full_name": "Ravi Kumar",
        "email": "ravi@gmail.com",
        "phone": "9876543210",
        "role": "Supervisor"
    }
    """
    try:
        # Get user info from JWT token (set by JWTAuthentication)
        user_uid = request.user['user_uid']
        
        # Get user from database
        user = get_user_by_uid(user_uid)
        
        if not user:
            return Response({
                'error': 'User not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        return Response({
            'full_name': user['full_name'],
            'email': user['email'],
            'phone': user['phone'],
            'role': get_role_name(user['role_id'])
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'error': f'Failed to get profile: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['PUT'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def update_profile(request):
    """
    API 2: Update User Profile
    
    PUT /api/user/profile/
    
    Headers:
    Authorization: Bearer <backend_bearer_token>
    
    Request body:
    {
        "full_name": "Ravi Kumar",
        "phone": "9876543210"
    }
    
    Response:
    {
        "message": "Profile updated successfully"
    }
    """
    try:
        # Get user info from JWT token
        user_uid = request.user['user_uid']
        email = request.user['email']

        # Get update data
        full_name = request.data.get('full_name')
        phone = request.data.get('phone')

        # Validate: Don't allow updating email, role, etc.
        if 'email' in request.data or 'role' in request.data or 'user_uid' in request.data:
            return Response({
                'error': 'Cannot update email, role, or user_uid'
            }, status=status.HTTP_400_BAD_REQUEST)

        # Try user_uid first; fall back to email for old tokens that lack user_uid
        if user_uid:
            success = update_user_profile(user_uid, full_name=full_name, phone=phone)
        elif email:
            success = update_user_profile_by_email(email, full_name=full_name, phone=phone)
        else:
            return Response({'error': 'Cannot identify user from token'}, status=status.HTTP_400_BAD_REQUEST)

        if not success:
            return Response({
                'error': 'Failed to update profile'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({
            'message': 'Profile updated successfully'
        }, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({
            'error': f'Failed to update profile: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
