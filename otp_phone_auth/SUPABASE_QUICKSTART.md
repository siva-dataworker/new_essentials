# Supabase Quick Start - 5 Minutes

## 1. Create Supabase Account (1 min)
- Go to https://supabase.com
- Click "Start your project"
- Sign up with GitHub/Google

## 2. Create Project (2 min)
- Click "New Project"
- Name: `essential-homes`
- Password: (save it!)
- Region: Choose closest
- Wait ~2 minutes for setup

## 3. Get Credentials (30 sec)
- Click Settings (⚙️) → API
- Copy:
  - **Project URL**
  - **anon public key**

## 4. Add to Your App (30 sec)
Open `lib/config/supabase_config.dart` and paste:
```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGci...';
```

## 5. Create Tables (1 min)
- Go to SQL Editor
- Copy-paste the SQL from `SUPABASE_SETUP.md` Step 3
- Click "Run"

## 6. Enable Phone Auth (Optional - for production)
- Go to Authentication → Providers
- Enable "Phone"
- Add Twilio credentials (or skip for now)

## 7. Install & Run
```bash
flutter pub get
flutter run
```

## Done! 🎉

Your app now has:
- ✅ Phone authentication
- ✅ PostgreSQL database
- ✅ Real-time updates
- ✅ File storage
- ✅ No Firebase complexity!

## For Development (No Phone Provider Yet)

If you haven't set up Twilio yet, you can:
1. Use email auth temporarily
2. Or add test phone numbers in Supabase Auth settings
3. Or continue with local SQLite for now

## Next Steps

See `SUPABASE_SETUP.md` for:
- Detailed table schemas
- Phone auth setup with Twilio
- Storage bucket configuration
- Security policies
