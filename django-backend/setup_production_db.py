#!/usr/bin/env python3
"""
Setup production database with initial users
Run this on Render after deployment
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.contrib.auth.models import User
from construction.models import Role, UserProfile

def create_users():
    """Create initial users for the system"""
    
    print("🔧 Setting up production database...")
    print()
    
    # Users to create
    users_data = [
        {
            'username': 'admin',
            'password': 'admin123',
            'email': 'admin@essentialhomes.com',
            'first_name': 'Admin',
            'last_name': 'User',
            'role': 'admin',
            'is_staff': True,
            'is_superuser': True,
        },
        {
            'username': 'siva',
            'password': 'siva123',
            'email': 'siva@essentialhomes.com',
            'first_name': 'Siva',
            'last_name': 'Kumar',
            'role': 'admin',
            'is_staff': True,
            'is_superuser': True,
        },
        {
            'username': 'accountant1',
            'password': 'accountant123',
            'email': 'accountant@essentialhomes.com',
            'first_name': 'Accountant',
            'last_name': 'User',
            'role': 'accountant',
        },
        {
            'username': 'supervisor1',
            'password': 'supervisor123',
            'email': 'supervisor@essentialhomes.com',
            'first_name': 'Supervisor',
            'last_name': 'User',
            'role': 'supervisor',
        },
        {
            'username': 'architect1',
            'password': 'architect123',
            'email': 'architect@essentialhomes.com',
            'first_name': 'Architect',
            'last_name': 'User',
            'role': 'architect',
        },
        {
            'username': 'client1',
            'password': 'client123',
            'email': 'client@essentialhomes.com',
            'first_name': 'Client',
            'last_name': 'User',
            'role': 'client',
        },
    ]
    
    # Get or create roles
    roles = {}
    role_names = ['admin', 'accountant', 'supervisor', 'architect', 'client', 'site_engineer']
    
    print("📋 Creating roles...")
    for role_name in role_names:
        role, created = Role.objects.get_or_create(name=role_name)
        roles[role_name] = role
        if created:
            print(f"  ✓ Created role: {role_name}")
        else:
            print(f"  ⏭️  Role exists: {role_name}")
    print()
    
    # Create users
    print("👥 Creating users...")
    for user_data in users_data:
        username = user_data['username']
        
        # Check if user exists
        if User.objects.filter(username=username).exists():
            print(f"  ⏭️  User exists: {username}")
            continue
        
        # Create user
        user = User.objects.create_user(
            username=user_data['username'],
            password=user_data['password'],
            email=user_data['email'],
            first_name=user_data['first_name'],
            last_name=user_data['last_name'],
            is_staff=user_data.get('is_staff', False),
            is_superuser=user_data.get('is_superuser', False),
        )
        
        # Create user profile
        role = roles[user_data['role']]
        UserProfile.objects.create(
            user=user,
            role=role,
            phone_number='+1234567890',
        )
        
        print(f"  ✓ Created user: {username} ({user_data['role']})")
    
    print()
    print("=" * 50)
    print("✅ Database setup complete!")
    print()
    print("Users created:")
    print("-" * 50)
    for user_data in users_data:
        print(f"Username: {user_data['username']}")
        print(f"Password: {user_data['password']}")
        print(f"Role: {user_data['role']}")
        print()

if __name__ == '__main__':
    create_users()
