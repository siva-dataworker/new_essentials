# Render Deployment Guide - Essential Homes Backend

## Overview
This guide will help you deploy the Django backend to Render.com with automatic deployment from GitHub.

## Prerequisites
- GitHub account
- Render account (free tier available)
- Supabase PostgreSQL database (already configured)

## Step 1: Push to GitHub

```bash
cd essential/construction_flutter

# Add all files (gitignore will exclude unnecessary files)
git add -A

# Commit
git commit -m "Initial commit: Essential Homes Construction Management System"

# Add GitHub remote
git remote add origin https://github.com/siva-dataworker/Essentials_construction_project.git

# Push to GitHub
git branch -M main
git push -u origin main --force
```

## Step 2: Prepare Render Configuration

### Files Created:
1. ✅ `render.yaml` - Render deployment configuration
2. ✅ `requirements.txt` - Updated with gunicorn and whitenoise
3. ✅ `.gitignore` - Excludes venv, build, media folders

### Django Settings Updates Needed:

Add to `django-backend/backend/settings.py`:

```python
# Static files configuration for Render
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATIC_URL = '/static/'

# Whitenoise for serving static files
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # Add this line
    # ... rest of middleware
]

# Whitenoise storage
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
```

## Step 3: Deploy to Render

### Option A: Using render.yaml (Recommended)

1. Go to https://render.com/
2. Sign in with GitHub
3. Click "New +" → "Blueprint"
4. Connect your GitHub repository: `Essentials_construction_project`
5. Render will automatically detect `render.yaml`
6. Click "Apply"

### Option B: Manual Setup

1. Go to https://render.com/
2. Click "New +" → "Web Service"
3. Connect GitHub repository
4. Configure:
   - **Name**: essential-homes-backend
   - **Region**: Singapore
   - **Branch**: main
   - **Root Directory**: `django-backend`
   - **Runtime**: Python 3
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn backend.wsgi:application`

## Step 4: Configure Environment Variables

In Render dashboard, add these environment variables:

### Required Variables:
```
SECRET_KEY=<generate-random-key>
DEBUG=False
ALLOWED_HOSTS=*

# Database (from Supabase)
DB_NAME=postgres
DB_USER=postgres.xxxxx
DB_PASSWORD=<your-supabase-password>
DB_HOST=<your-supabase-host>.supabase.co
DB_PORT=5432
```

### Get Supabase Credentials:
1. Go to Supabase dashboard
2. Project Settings → Database
3. Copy connection details

## Step 5: Deploy

1. Click "Create Web Service" or "Deploy"
2. Wait for build to complete (5-10 minutes)
3. Your backend will be live at: `https://essential-homes-backend.onrender.com`

## Step 6: Update Flutter App

Update all IP addresses in Flutter app to Render URL:

```dart
// In all service files
static const String baseUrl = 'https://essential-homes-backend.onrender.com/api';
```

Files to update:
- `otp_phone_auth/lib/services/auth_service.dart`
- `otp_phone_auth/lib/services/backend_service.dart`
- `otp_phone_auth/lib/services/construction_service.dart`
- All other service files

## Step 7: Test Deployment

```bash
# Test API endpoint
curl https://essential-homes-backend.onrender.com/api/

# Test login
curl -X POST https://essential-homes-backend.onrender.com/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

## Automatic Deployment Pipeline

Once set up, the pipeline works like this:

```
Local Development → Git Push → GitHub → Render Auto-Deploy → Live Backend
```

Every time you push to GitHub main branch:
1. Render detects the push
2. Automatically builds the new version
3. Runs migrations (if configured)
4. Deploys the new version
5. Zero downtime deployment

## Render Free Tier Limitations

- ⚠️ Service spins down after 15 minutes of inactivity
- ⚠️ First request after spin-down takes 30-60 seconds
- ✅ 750 hours/month free
- ✅ Automatic HTTPS
- ✅ Custom domains supported

## Upgrade to Paid Plan (Optional)

For production use, consider upgrading:
- **Starter Plan**: $7/month
  - Always on (no spin-down)
  - Faster response times
  - More resources

## Troubleshooting

### Build Fails:
- Check `requirements.txt` is correct
- Verify Python version compatibility
- Check Render build logs

### Database Connection Fails:
- Verify Supabase credentials
- Check if Supabase allows connections from Render IPs
- Test connection string manually

### Static Files Not Loading:
- Run `python manage.py collectstatic` in build command
- Verify whitenoise is installed
- Check STATIC_ROOT setting

## Monitoring

Render provides:
- Real-time logs
- Metrics dashboard
- Health checks
- Email alerts

## Backup Strategy

1. Database: Supabase handles backups
2. Code: GitHub is your backup
3. Media files: Consider AWS S3 or Cloudinary

## Next Steps

1. ✅ Push code to GitHub
2. ✅ Connect Render to GitHub
3. ✅ Configure environment variables
4. ✅ Deploy backend
5. ✅ Update Flutter app with Render URL
6. ✅ Test all features
7. ✅ Monitor logs

## Support

- Render Docs: https://render.com/docs
- Django Deployment: https://docs.djangoproject.com/en/5.0/howto/deployment/
- Supabase Docs: https://supabase.com/docs
