# Django Backend for OTP Phone Auth (Optional)

This Django backend provides additional user management and API endpoints for the Flutter OTP app.

## Setup

### 1. Create Virtual Environment
```bash
cd django_backend
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Create Django Project
```bash
django-admin startproject backend .
python manage.py startapp users
```

### 4. Firebase Admin SDK Setup

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Save the JSON file as `serviceAccountKey.json` in the backend folder
4. Add to `.gitignore`:
```
serviceAccountKey.json
```

### 5. Configure Django Settings

Add to `backend/settings.py`:

```python
INSTALLED_APPS = [
    # ...
    'rest_framework',
    'corsheaders',
    'users',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    # ... other middleware
]

# CORS settings
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
]

# For development only
CORS_ALLOW_ALL_ORIGINS = True

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'users.authentication.FirebaseAuthentication',
    ],
}
```

### 6. Run Migrations
```bash
python manage.py makemigrations
python manage.py migrate
```

### 7. Run Server
```bash
python manage.py runserver
```

## API Endpoints

### Verify User
```
POST /api/users/verify/
Headers: Authorization: Bearer <firebase_id_token>
Response: {
    "status": "success",
    "uid": "firebase_user_id",
    "phone": "+1234567890"
}
```

### Get User Profile
```
GET /api/users/profile/
Headers: Authorization: Bearer <firebase_id_token>
Response: {
    "uid": "firebase_user_id",
    "phone": "+1234567890",
    "created_at": "2024-01-01T00:00:00Z"
}
```

## Integration with Flutter

In your Flutter app, after successful authentication:

```dart
import 'package:http/http.dart' as http;

Future<void> syncWithBackend() async {
  final user = FirebaseAuth.instance.currentUser;
  final token = await user?.getIdToken();
  
  final response = await http.post(
    Uri.parse('http://your-backend-url/api/users/verify/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    print('User synced with backend');
  }
}
```

## File Structure

```
django_backend/
├── backend/
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── users/
│   ├── models.py
│   ├── views.py
│   ├── serializers.py
│   ├── authentication.py
│   └── urls.py
├── serviceAccountKey.json  (not in git)
├── requirements.txt
└── manage.py
```
