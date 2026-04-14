# 🔥 Install Firebase CLI - Step by Step

## 🎯 Why You Need This

You tried to run:
```cmd
flutterfire configure --project=construction-4a98c
```

But got this error:
```
The FlutterFire CLI currently requires the official Firebase CLI to also be installed
```

**Solution**: Install Firebase CLI first!

---

## ⚡ Quick Install (Choose ONE Method)

### Method 1: Using npm (Fastest - 30 seconds)

**If you have Node.js installed:**

```cmd
npm install -g firebase-tools
```

**Verify:**
```cmd
firebase --version
```

You should see something like: `13.0.0` or similar

---

### Method 2: Standalone Installer (No Node.js needed)

**Download and run:**

1. Download: https://firebase.tools/bin/win/instant/latest
2. Run the downloaded `.exe` file
3. Follow installation wizard
4. Restart your terminal/command prompt

**Verify:**
```cmd
firebase --version
```

---

### Method 3: Using Chocolatey (Windows Package Manager)

**If you have Chocolatey:**

```cmd
choco install firebase-cli
```

**Verify:**
```cmd
firebase --version
```

---

## ✅ After Installation

### Step 1: Login to Firebase
```cmd
firebase login
```

This will:
- Open your browser
- Ask you to sign in with Google
- Authorize Firebase CLI

### Step 2: Configure FlutterFire
```cmd
cd otp_phone_auth
flutterfire configure --project=construction-4a98c
```

This will:
- ✅ Connect to your Firebase project
- ✅ Auto-generate `lib/firebase_options.dart`
- ✅ Configure Android, iOS, Web platforms

### Step 3: Continue Setup
```cmd
flutter pub get
```

---

## 🐛 Troubleshooting

### "npm is not recognized"

You need to install Node.js first:

1. Download: https://nodejs.org/
2. Install the **LTS version** (recommended)
3. Restart your terminal
4. Try again: `npm install -g firebase-tools`

---

### "firebase is not recognized" (After installation)

**Solution 1**: Restart terminal
- Close your command prompt/PowerShell
- Open a new one
- Try: `firebase --version`

**Solution 2**: Restart computer
- Sometimes Windows needs a restart to update PATH
- Restart and try again

**Solution 3**: Check installation
- Standalone installer: Re-run the installer
- npm: Try `npm install -g firebase-tools` again

---

### "Permission denied" (npm)

**Windows**: Run as Administrator
```cmd
# Right-click Command Prompt → Run as Administrator
npm install -g firebase-tools
```

---

### "Cannot find module" errors

**Clean npm cache:**
```cmd
npm cache clean --force
npm install -g firebase-tools
```

---

## 📋 Complete Command Flow

```cmd
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Verify installation
firebase --version

# 3. Login to Firebase
firebase login

# 4. Navigate to Flutter project
cd otp_phone_auth

# 5. Configure FlutterFire
flutterfire configure --project=construction-4a98c

# 6. Get Flutter dependencies
flutter pub get

# 7. Run app
flutter run
```

---

## 🎯 What Happens After Installation

Once Firebase CLI is installed and you run `flutterfire configure`:

1. **Connects to Firebase**: Links to your `construction-4a98c` project
2. **Generates Config**: Creates `lib/firebase_options.dart` automatically
3. **Platform Setup**: Configures Android, iOS, Web, etc.
4. **Ready to Use**: Firebase is ready in your Flutter app!

---

## ⏱️ Time Required

- **npm method**: 30 seconds
- **Standalone installer**: 2 minutes
- **Login + Configure**: 3 minutes
- **Total**: ~5 minutes

---

## 📚 Next Steps After Installation

1. ✅ Firebase CLI installed
2. ✅ Login to Firebase
3. ✅ Configure FlutterFire
4. ⏳ Update main.dart (see `START_NOW.md`)
5. ⏳ Enable Google Sign-In (see `GOOGLE_AUTH_QUICK_START.md`)
6. ⏳ Add SHA-1 (run `get_sha1.bat`)
7. ⏳ Test app (`flutter run`)

---

## 🔗 Resources

- **Firebase CLI Docs**: https://firebase.google.com/docs/cli
- **Node.js Download**: https://nodejs.org/
- **Standalone Installer**: https://firebase.tools/bin/win/instant/latest
- **FlutterFire Docs**: https://firebase.flutter.dev/

---

## 💡 Quick Help

**After installing Firebase CLI, see:**
- `START_NOW.md` - Complete setup guide
- `FIREBASE_CLI_SETUP.md` - Detailed Firebase setup
- `GOOGLE_AUTH_QUICK_START.md` - Quick Firebase guide

---

## ✨ Summary

1. **Install**: `npm install -g firebase-tools`
2. **Verify**: `firebase --version`
3. **Login**: `firebase login`
4. **Configure**: `flutterfire configure --project=construction-4a98c`
5. **Done**: Continue with `START_NOW.md`

---

**Start now:**
```cmd
npm install -g firebase-tools
```

**Then see: `START_NOW.md`** 🚀
