# Render Deployment Credentials & Setup

## Render Account Setup

### Step 1: Create Render Account
1. Go to https://render.com
2. Click "Get Started" or "Sign Up"
3. Sign up with your GitHub account (recommended)
   - Or use email: [your-email@example.com]
4. Verify your email

### Step 2: Connect GitHub Repository
1. In Render dashboard, click "New +" → "Web Service"
2. Click "Connect GitHub"
3. Authorize Render to access your repositories
4. Select repository: `siva-dataworker/new_essentials`

## Environment Variables for Render

When setting up the web service, add these environment variables:

### Django Settings
```
SECRET_KEY=django-insecure-essential-homes-2024-change-in-production
DEBUG=False
ALLOWED_HOSTS=*
```

### Database (Supabase)
```
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=Appdevlopment@2026
DB_HOST=db.ctwthgjuccioxivnzifb.supabase.co
DB_PORT=5432
```

### JWT Settings
```
JWT_SECRET_KEY=essential-homes-jwt-secret-2024-change-in-production
```

## Render Service Configuration

### Basic Settings:
- **Name**: essential-homes-backend
- **Region**: Singapore (or closest to your users)
- **Branch**: main
- **Root Directory**: `django-backend`
- **Runtime**: Python 3

### Build Settings:
- **Build Command**: 
  ```bash
  pip install -r requirements.txt && python manage.py collectstatic --noinput
  ```

- **Start Command**: 
  ```bash
  gunicorn backend.wsgi:application --bind 0.0.0.0:$PORT
  ```

### Plan:
- **Free Tier**: 
  - 750 hours/month
  - Spins down after 15 minutes of inactivity
  - First request after spin-down takes 30-60 seconds

- **Starter Plan** ($7/month - Recommended for production):
  - Always on (no spin-down)
  - Faster response times
  - Better for production use

## Deployment URL

After deployment, your backend will be available at:
```
https://essential-homes-backend.onrender.com
```

Or whatever name you choose:
```
https://[your-service-name].onrender.com
```

## Database Credentials (Supabase)

Already configured and working:

- **Host**: db.ctwthgjuccioxivnzifb.supabase.co
- **Database**: postgres
- **User**: postgres
- **Password**: Appdevlopment@2026
- **Port**: 5432

### Supabase Dashboard Access:
1. Go to https://supabase.com
2. Login with your account
3. Select project: Essential Homes Construction

## After Deployment: Update Flutter App

Once your Render backend is live, update the Flutter app URLs:

### Files to Update:
All service files in `otp_phone_auth/lib/services/`:

```dart
// Replace this:
static const String baseUrl = 'http://192.168.1.11:8000/api';

// With this:
static const String baseUrl = 'https://essential-homes-backend.onrender.com/api';
```

### Quick Update Script:
```bash
cd essential/essential/construction_flutter/otp_phone_auth

# Find all files with the old URL
grep -r "192.168.1.11:8000" lib/services/

# Replace with Render URL (after deployment)
# Use find and replace in your editor
```

## Testing Deployment

### Test API Health:
```bash
curl https://essential-homes-backend.onrender.com/api/
```

### Test Login:
```bash
curl -X POST https://essential-homes-backend.onrender.com/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

## Monitoring & Logs

### View Logs:
1. Go to Render dashboard
2. Select your service
3. Click "Logs" tab
4. View real-time logs

### Metrics:
- CPU usage
- Memory usage
- Request count
- Response times

## Automatic Deployments

Once connected to GitHub:
1. Push code to GitHub: `git push origin main`
2. Render automatically detects the push
3. Builds and deploys new version
4. Zero downtime deployment

## Troubleshooting

### Service Won't Start:
- Check environment variables are set correctly
- View logs for error messages
- Verify database connection

### Database Connection Error:
- Verify Supabase credentials
- Check if Supabase allows connections from Render
- Test connection string manually

### Static Files Not Loading:
- Ensure `collectstatic` runs in build command
- Check `whitenoise` is installed
- Verify `STATIC_ROOT` in settings.py

## Security Notes

⚠️ **Important**: Change these in production:
- `SECRET_KEY`: Generate a new random key
- `JWT_SECRET_KEY`: Generate a new random key
- `DB_PASSWORD`: Use a strong password

### Generate New Secret Keys:
```python
# In Python shell:
from django.core.management.utils import get_random_secret_key
print(get_random_secret_key())
```

## Backup & Recovery

### Database Backups:
- Supabase handles automatic backups
- Can restore from Supabase dashboard

### Code Backups:
- GitHub is your source of truth
- Render pulls from GitHub

### Media Files:
- Consider using AWS S3 or Cloudinary for production
- Render's filesystem is ephemeral (resets on deploy)

## Cost Estimate

### Free Tier:
- Backend: Free (with spin-down)
- Database: Supabase free tier (500MB)
- Total: $0/month

### Production Setup:
- Backend: $7/month (Starter plan)
- Database: Supabase Pro $25/month (8GB, better performance)
- Total: $32/month

## Support Resources

- **Render Docs**: https://render.com/docs
- **Render Community**: https://community.render.com
- **Django Deployment**: https://docs.djangoproject.com/en/5.0/howto/deployment/
- **Supabase Docs**: https://supabase.com/docs

## Quick Start Checklist

- [ ] Create Render account
- [ ] Connect GitHub repository
- [ ] Configure environment variables
- [ ] Set build and start commands
- [ ] Deploy service
- [ ] Test API endpoints
- [ ] Update Flutter app URLs
- [ ] Rebuild Flutter app
- [ ] Test end-to-end

## Summary

Your backend is ready to deploy to Render with:
- ✅ Database configured (Supabase)
- ✅ Environment variables documented
- ✅ Build commands ready
- ✅ GitHub repository ready
- ✅ Free tier available

Just sign up on Render and follow the steps above!
