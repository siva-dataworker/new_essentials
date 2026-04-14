# Django Backend - Essential Homes

Django REST API backend connected to Supabase PostgreSQL.

## Quick Start

### 1. Setup (First Time Only)

```cmd
setup.bat
```

This will:
- Create virtual environment
- Install dependencies
- Run database migrations

### 2. Run the Server

```cmd
run.bat
```

Server will start at: http://localhost:8000

## API Endpoints

### Health Checks
- `GET /api/health/` - Service health check
- `GET /api/health/db/` - Database connection test

### Users
- `GET /api/users/` - List all users
- `POST /api/users/` - Create new user
- `GET /api/users/{id}/` - Get user by ID
- `PUT /api/users/{id}/` - Update user
- `DELETE /api/users/{id}/` - Delete user

### Sites
- `GET /api/sites/` - List all sites
- `POST /api/sites/` - Create new site
- `GET /api/sites/{id}/` - Get site by ID
- `PUT /api/sites/{id}/` - Update site
- `DELETE /api/sites/{id}/` - Delete site

## Configuration

Database credentials are in `.env`:
```
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=Appdevlopment@2026
DB_HOST=db.ctwthgjuccioxivnzifb.supabase.co
DB_PORT=5432
```

## Test the API

### Using Browser
- http://localhost:8000/api/health/
- http://localhost:8000/api/health/db/
- http://localhost:8000/api/users/
- http://localhost:8000/api/sites/

### Using curl

**Create a user:**
```bash
curl -X POST http://localhost:8000/api/users/ ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"John Doe\",\"phone_number\":\"+1234567890\",\"role\":\"supervisor\"}"
```

**Get all users:**
```bash
curl http://localhost:8000/api/users/
```

## Project Structure

```
django-backend/
├── backend/              # Django project settings
│   ├── settings.py      # Configuration
│   ├── urls.py          # Main URL routing
│   └── wsgi.py          # WSGI config
├── api/                 # API app
│   ├── models.py        # Database models
│   ├── serializers.py   # REST serializers
│   ├── views.py         # API views
│   ├── urls.py          # API URL routing
│   └── admin.py         # Admin interface
├── manage.py            # Django management
├── requirements.txt     # Python dependencies
├── .env                 # Database credentials
├── setup.bat           # Setup script
└── run.bat             # Run script
```

## Features

- ✅ Connected to Supabase PostgreSQL
- ✅ REST API with Django REST Framework
- ✅ CORS enabled for Flutter app
- ✅ Health check endpoints
- ✅ User and Site management
- ✅ Admin interface at /admin/
- ✅ Auto-generated API documentation

## Troubleshooting

**Can't connect to database?**
- Check internet connection
- Verify credentials in `.env`
- Visit Supabase dashboard to wake up project

**Port 8000 in use?**
- Edit `run.bat` and change port: `python manage.py runserver 8001`

**Dependencies not installing?**
- Make sure Python 3.8+ is installed
- Try: `pip install --upgrade pip`
