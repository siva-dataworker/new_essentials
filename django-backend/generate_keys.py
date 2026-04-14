"""
Generate secure random keys for Django SECRET_KEY and JWT_SECRET_KEY
"""
import secrets
import string

def generate_secret_key(length=50):
    """Generate a secure random string"""
    chars = string.ascii_letters + string.digits + '!@#$%^&*(-_=+)'
    return ''.join(secrets.choice(chars) for _ in range(length))

print("=" * 60)
print("SECURE KEYS FOR RENDER DEPLOYMENT")
print("=" * 60)

# Generate Django SECRET_KEY
django_secret = generate_secret_key(50)
print("\n1. SECRET_KEY:")
print(f"   {django_secret}")

# Generate JWT_SECRET_KEY
jwt_secret = generate_secret_key(50)
print("\n2. JWT_SECRET_KEY:")
print(f"   {jwt_secret}")

print("\n" + "=" * 60)
print("Copy these values to Render environment variables")
print("=" * 60)
