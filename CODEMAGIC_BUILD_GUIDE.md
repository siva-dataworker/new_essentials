# Build APK with Codemagic (Cloud Build)

## Why Use Codemagic?

Your app runs on web but has Gradle build issues locally. Codemagic builds in a clean cloud environment, avoiding local issues.

## Benefits

✅ No local Gradle/Kotlin issues
✅ Clean build environment every time
✅ Automatic APK generation
✅ Free tier: 500 build minutes/month
✅ Builds while you work on other things

## Step-by-Step Setup

### 1. Sign Up

1. Go to https://codemagic.io
2. Click "Sign up with GitHub"
3. Authorize Codemagic to access your repositories

### 2. Add Your App

1. In Codemagic dashboard, click "Add application"
2. Select "GitHub"
3. Choose repository: `siva-dataworker/new_essentials`
4. Click "Finish: Add application"

### 3. Configure Project

1. Select "Flutter App" as project type
2. Set project path: `otp_phone_auth`
3. Click "Start your first build"

### 4. Build Settings (First Time)

Codemagic will auto-detect your Flutter project. You can use:

**Option A: Use codemagic.yaml (Already Created)**
- The `codemagic.yaml` file is already in your repo
- Codemagic will automatically use it
- Just click "Start new build"

**Option B: Use Workflow Editor (GUI)**
- Click "Workflow Editor" in Codemagic
- Configure these settings:
  - Flutter version: Stable
  - Build format: APK
  - Build mode: Release
  - Project path: `otp_phone_auth`

### 5. Start Build

1. Click "Start new build"
2. Select branch: `main`
3. Wait 5-10 minutes for build to complete
4. Download APK from "Artifacts" section

## Build Configuration (codemagic.yaml)

Already created and pushed to your repo. It will:
- Use Flutter stable version
- Build release APK
- Save APK as artifact
- Send email notification when done

## After Build Completes

1. Go to "Builds" tab in Codemagic
2. Click on your completed build
3. Scroll to "Artifacts" section
4. Download `app-release.apk`
5. Transfer to your phone and install

## Install APK on Phone

### Method 1: Direct Download
1. Open Codemagic build page on your phone
2. Download APK directly
3. Allow "Install from unknown sources"
4. Install the APK

### Method 2: Transfer from Computer
1. Download APK on computer
2. Connect phone via USB
3. Copy APK to phone's Download folder
4. Open file manager on phone
5. Tap APK to install

## Troubleshooting

### Build Fails with "Flutter not found"
- Codemagic auto-installs Flutter, this shouldn't happen
- Check project path is set to `otp_phone_auth`

### Build Fails with "Gradle error"
- Codemagic uses clean environment, so this is rare
- Check `codemagic.yaml` syntax
- Ensure `android/build.gradle.kts` is valid

### APK Won't Install on Phone
- Enable "Install from unknown sources" in phone settings
- Check phone Android version (minimum: Android 5.0)

### Build Takes Too Long
- First build: 10-15 minutes (normal)
- Subsequent builds: 5-8 minutes (cached)

## Free Tier Limits

- 500 build minutes/month
- Unlimited team members
- Unlimited apps
- Each build takes ~8 minutes
- You can do ~60 builds/month for free

## Next Steps After First Build

1. Test APK on your phone
2. If it works, you can:
   - Set up automatic builds on every push
   - Add signing keys for Play Store
   - Configure different build variants (debug/release)

## Alternative: GitHub Actions

If you prefer GitHub Actions instead of Codemagic:
- Free tier: 2000 minutes/month
- Requires more configuration
- Let me know if you want to try this instead

## Quick Commands

### Push changes and trigger build:
```bash
cd essential/essential/construction_flutter
git add .
git commit -m "Your changes"
git push origin main
```

Then go to Codemagic and click "Start new build"

### Update Codemagic config:
Edit `codemagic.yaml` and push to GitHub.

## Support

- Codemagic Docs: https://docs.codemagic.io/flutter/
- Codemagic Slack: https://codemagic.io/slack
- Email: support@codemagic.io

## Summary

Codemagic solves your local Gradle build issues by building in the cloud. It's the fastest way to get an APK without fixing local environment problems.
