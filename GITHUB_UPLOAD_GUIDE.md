# GitHub Upload Guide - Essential Files Only

## Folder Sizes Analysis

### Current Sizes:
- **django-backend**: 242.7 MB (mostly venv: 202.96 MB + media: 37.62 MB)
- **otp_phone_auth**: 82.8 MB (mostly build: 56.46 MB)
- **flutter_application_1**: 44.25 MB (not needed)
- Other folders: < 1 MB

### What to Upload:

## Essential Files (< 10 MB total):

### 1. Django Backend (Core Files Only)
Upload these folders/files:
- ✅ `django-backend/api/` (1.41 MB) - All Python API code
- ✅ `django-backend/backend/` (0.02 MB) - Django settings
- ✅ `django-backend/*.py` - All Python scripts
- ✅ `django-backend/*.sql` - Database migration scripts
- ✅ `django-backend/*.bat` - Startup scripts
- ✅ `django-backend/requirements.txt` - Dependencies

DO NOT upload:
- ❌ `django-backend/venv/` (202.96 MB) - Virtual environment (recreate with `pip install -r requirements.txt`)
- ❌ `django-backend/media/` (37.62 MB) - Uploaded files (user data)

### 2. Flutter Frontend (Core Files Only)
Upload these folders/files:
- ✅ `otp_phone_auth/lib/` (2.13 MB) - All Dart code
- ✅ `otp_phone_auth/android/app/` - Android config (without build/)
- ✅ `otp_phone_auth/ios/` (0.06 MB) - iOS config
- ✅ `otp_phone_auth/pubspec.yaml` - Dependencies
- ✅ `otp_phone_auth/pubspec.lock` - Locked dependencies
- ✅ `otp_phone_auth/assets/` (0.02 MB) - Images/fonts

DO NOT upload:
- ❌ `otp_phone_auth/build/` (56.46 MB) - Build artifacts (recreate with `flutter build`)
- ❌ `otp_phone_auth/android/build/` - Android build files
- ❌ `otp_phone_auth/.dart_tool/` - Dart tools cache

### 3. Documentation (Optional)
- ✅ All `.md` files in root (feature documentation)
- ✅ `README.md` - Project overview

### 4. DO NOT Upload:
- ❌ `flutter_application_1/` (44.25 MB) - Old/unused project
- ❌ `spring-backend/` - Empty folder
- ❌ `.kiro/`, `.claude/`, `.idea/` - IDE configs
- ❌ Any `.zip` files

## Final Size After Cleanup:
**Estimated: 5-10 MB** (without venv, build, media folders)

## Steps to Upload:

### Option 1: Clean Push (Recommended)

```bash
cd essential/construction_flutter

# Remove git history
Remove-Item -Recurse -Force .git

# Initialize fresh repository
git init
git add .gitignore
git add django-backend/api/
git add django-backend/backend/
git add django-backend/*.py
git add django-backend/*.sql
git add django-backend/*.bat
git add django-backend/requirements.txt
git add otp_phone_auth/lib/
git add otp_phone_auth/android/app/src/
git add otp_phone_auth/pubspec.*
git add otp_phone_auth/assets/
git add *.md
git add README.md

# Commit
git commit -m "Initial commit: Construction Management System - Core files only"

# Push to GitHub
git remote add origin https://github.com/siva-dataworker/Essentials_construction_project.git
git branch -M main
git push -u origin main --force
```

### Option 2: Use .gitignore (Easier)

```bash
cd essential/construction_flutter

# Remove git history
Remove-Item -Recurse -Force .git

# Initialize with .gitignore
git init
git add -A

# Commit (will automatically exclude files in .gitignore)
git commit -m "Initial commit: Construction Management System"

# Push to GitHub
git remote add origin https://github.com/siva-dataworker/Essentials_construction_project.git
git branch -M main
git push -u origin main --force
```

## After Cloning from GitHub:

### Setup Django Backend:
```bash
cd django-backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### Setup Flutter Frontend:
```bash
cd otp_phone_auth
flutter pub get
flutter build apk
```

## Summary:

✅ **Upload**: Source code, configs, documentation (5-10 MB)
❌ **Don't Upload**: Build artifacts, dependencies, user data (280+ MB)

The .gitignore file I created will automatically exclude unnecessary files.
