# Example Django Users App Implementation
# Create these files in your Django users app

# ============================================
# users/models.py
# ============================================
from django.db import models

class User(models.Model):
    firebase_uid = models.CharField(max_length=128, unique=True)
    phone_number = models.CharField(max_length=20)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.phone_number} ({self.firebase_uid})"

    class Meta:
        db_table = 'users'


# ============================================
# users/authentication.py
# ============================================
from rest_framework import authentication
from rest_framework import exceptions
from firebase_admin import auth, credentials, initialize_app
import firebase_admin

# Initialize Firebase Admin SDK
if not firebase_admin._apps:
    cred = credentials.Certificate('serviceAccountKey.json')
    initialize_app(cred)

class FirebaseAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.META.get('HTTP_AUTHORIZATION')
        if not auth_header:
            return None

        try:
            # Extract token from "Bearer <token>"
            token = auth_header.split(' ')[1]
            decoded_token = auth.verify_id_token(token)
            uid = decoded_token['uid']
            
            # Return user info
            return (decoded_token, None)
        except Exception as e:
            raise exceptions.AuthenticationFailed(f'Invalid token: {str(e)}')


# ============================================
# users/serializers.py
# ============================================
from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'firebase_uid', 'phone_number', 'created_at', 'is_active']
        read_only_fields = ['id', 'created_at']


# ============================================
# users/views.py
# ============================================
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import User
from .serializers import UserSerializer

@api_view(['POST'])
def verify_user(request):
    """Verify Firebase token and create/update user"""
    auth_header = request.META.get('HTTP_AUTHORIZATION')
    if not auth_header:
        return Response(
            {'error': 'No authorization header'},
            status=status.HTTP_401_UNAUTHORIZED
        )

    try:
        from firebase_admin import auth
        token = auth_header.split(' ')[1]
        decoded_token = auth.verify_id_token(token)
        
        uid = decoded_token['uid']
        phone = decoded_token.get('phone_number', '')
        
        # Create or update user
        user, created = User.objects.update_or_create(
            firebase_uid=uid,
            defaults={'phone_number': phone}
        )
        
        return Response({
            'status': 'success',
            'uid': uid,
            'phone': phone,
            'created': created
        })
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_401_UNAUTHORIZED
        )

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_profile(request):
    """Get user profile"""
    try:
        uid = request.user['uid']
        user = User.objects.get(firebase_uid=uid)
        serializer = UserSerializer(user)
        return Response(serializer.data)
    except User.DoesNotExist:
        return Response(
            {'error': 'User not found'},
            status=status.HTTP_404_NOT_FOUND
        )

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_profile(request):
    """Update user profile"""
    try:
        uid = request.user['uid']
        user = User.objects.get(firebase_uid=uid)
        serializer = UserSerializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    except User.DoesNotExist:
        return Response(
            {'error': 'User not found'},
            status=status.HTTP_404_NOT_FOUND
        )


# ============================================
# users/urls.py
# ============================================
from django.urls import path
from . import views

urlpatterns = [
    path('verify/', views.verify_user, name='verify_user'),
    path('profile/', views.get_profile, name='get_profile'),
    path('profile/update/', views.update_profile, name='update_profile'),
]


# ============================================
# backend/urls.py (main urls.py)
# ============================================
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/users/', include('users.urls')),
]
