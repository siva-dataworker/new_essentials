# Fix Document 404 Error on Render

## Problem

Documents uploaded to the backend return 404 error when accessed:
- URL: `https://new-essentials.onrender.com/media/architect_documents/...`
- Error: Page not found (404)
- Files exist on server but Django can't serve them

## Root Cause

1. `DEBUG = True` was hardcoded in settings.py
2. Media files were only served when `DEBUG = True`
3. In production, Django needs explicit configuration to serve media files

## Solution Applied

### 1. Updated settings.py
Changed:
```python
DEBUG = True  # Hardcoded
```

To:
```python
DEBUG = config('DEBUG', default=False, cast=bool)  # From environment variable
```

### 2. Updated urls.py
Added production media file serving:
```python
if settings.DEBUG:
    # Development
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
else:
    # Production - serve media files directly
    urlpatterns += [
        re_path(r'^media/(?P<path>.*)$', serve, {
            'document_root': settings.MEDIA_ROOT,
        }),
    ]
```

## Render Configuration

### Option 1: Keep DEBUG = True (Quick Fix)
Add this environment variable in Render:
```
DEBUG=True
```

**Pros**: Quick fix, documents will work immediately
**Cons**: Not recommended for production (security risk, shows detailed errors)

### Option 2: Proper Production Setup (Recommended)
1. Set `DEBUG=False` in Render environment variables
2. Media files will be served via the updated urls.py configuration
3. More secure for production

### Option 3: Use Cloud Storage (Best Practice)
For production, it's better to use cloud storage like:
- AWS S3
- Google Cloud Storage
- Cloudinary
- Supabase Storage

This way, media files are served from CDN instead of Django.

## Testing

After deploying to Render:

1. Upload a document via the app
2. Try to open it from Reports screen
3. Document should open/download successfully

## Files Modified

1. `django-backend/backend/settings.py` - Made DEBUG configurable
2. `django-backend/backend/urls.py` - Added production media serving

## Deployment Steps

1. Commit and push changes to GitHub
2. Render will auto-deploy
3. Add `DEBUG=True` environment variable in Render (temporary)
4. Test document opening
5. Later, migrate to cloud storage for better performance

## Alternative: Nginx Configuration

If using Nginx in front of Django, configure it to serve media files:

```nginx
location /media/ {
    alias /opt/render/project/src/django-backend/media/;
}
```

## Security Note

When `DEBUG = False`, make sure to:
- Set proper `ALLOWED_HOSTS`
- Use strong `SECRET_KEY`
- Enable HTTPS
- Configure proper CORS settings

Current settings already have these configured.
