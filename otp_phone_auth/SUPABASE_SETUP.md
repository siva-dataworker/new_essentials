# Supabase Setup Guide

## Why Supabase?
- ✅ **Simpler** than Firebase - no complex configuration
- ✅ **PostgreSQL** database - powerful and familiar
- ✅ **Built-in Auth** - phone OTP included
- ✅ **Real-time** subscriptions
- ✅ **Storage** for photos
- ✅ **Free tier** - generous limits

## Step 1: Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up / Log in
3. Click **"New Project"**
4. Fill in:
   - **Name**: Essential Homes Construction
   - **Database Password**: (save this!)
   - **Region**: Choose closest to you
5. Click **"Create new project"** (takes ~2 minutes)

## Step 2: Get Your Credentials

1. In your Supabase project dashboard
2. Go to **Settings** (gear icon) → **API**
3. Copy these two values:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon public** key (long string starting with `eyJ...`)

4. Open `lib/config/supabase_config.dart`
5. Replace:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

## Step 3: Create Database Tables

In Supabase Dashboard → **SQL Editor**, run this:

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  phone_number TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('supervisor', 'site_engineer', 'architect', 'accountant', 'owner')),
  site_id UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sites table
CREATE TABLE sites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  location TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Daily entries table
CREATE TABLE daily_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  date DATE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Material entries table
CREATE TABLE material_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  material_name TEXT NOT NULL,
  quantity DECIMAL NOT NULL,
  unit TEXT NOT NULL,
  date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Labor entries table
CREATE TABLE labor_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  labor_type TEXT NOT NULL,
  count INTEGER NOT NULL,
  date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Photos table
CREATE TABLE photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  url TEXT NOT NULL,
  description TEXT,
  date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE sites ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE material_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE labor_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;

-- Policies (allow authenticated users to read/write their data)
CREATE POLICY "Users can read all users" ON users FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can read all sites" ON sites FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Users can read all entries" ON daily_entries FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can create entries" ON daily_entries FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can read all material entries" ON material_entries FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can create material entries" ON material_entries FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can read all labor entries" ON labor_entries FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can create labor entries" ON labor_entries FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can read all photos" ON photos FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can create photos" ON photos FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

## Step 4: Enable Phone Authentication

1. In Supabase Dashboard → **Authentication** → **Providers**
2. Enable **Phone** provider
3. Choose a provider:
   - **Twilio** (recommended, $0.0079/SMS)
   - **MessageBird**
   - **Vonage**
4. Add your provider credentials

### Twilio Setup (Recommended):
1. Go to [https://www.twilio.com](https://www.twilio.com)
2. Sign up and get a phone number
3. Copy:
   - Account SID
   - Auth Token
   - Phone Number
4. Paste into Supabase Phone Auth settings

## Step 5: Create Storage Bucket

1. In Supabase Dashboard → **Storage**
2. Click **"New bucket"**
3. Name: `photos`
4. Make it **Public** (for easy photo access)
5. Click **"Create bucket"**

## Step 6: Install Dependencies

Run in your terminal:
```bash
cd otp_phone_auth
flutter pub get
```

## Step 7: Update main.dart

The app will initialize Supabase on startup. Make sure `main.dart` calls:
```dart
await SupabaseService.initialize(
  supabaseUrl: SupabaseConfig.supabaseUrl,
  supabaseAnonKey: SupabaseConfig.supabaseAnonKey,
);
```

## Step 8: Test

Run your app:
```bash
flutter run
```

## Quick Reference

### Supabase Dashboard URLs:
- **Project**: https://app.supabase.com/project/YOUR_PROJECT_ID
- **Database**: https://app.supabase.com/project/YOUR_PROJECT_ID/editor
- **Auth**: https://app.supabase.com/project/YOUR_PROJECT_ID/auth/users
- **Storage**: https://app.supabase.com/project/YOUR_PROJECT_ID/storage/buckets

### Common Operations:
```dart
// Get Supabase instance
final supabase = SupabaseService();

// Sign in with phone
await supabase.signInWithOTP('+1234567890');

// Verify OTP
await supabase.verifyOTP(phoneNumber: '+1234567890', token: '123456');

// Get current user
final user = supabase.currentUser;

// Create user profile
await supabase.createUserProfile(
  userId: user!.id,
  name: 'John Doe',
  phoneNumber: '+1234567890',
  role: 'supervisor',
);

// Get sites
final sites = await supabase.getSites();

// Sign out
await supabase.signOut();
```

## Advantages Over Firebase

| Feature | Supabase | Firebase |
|---------|----------|----------|
| Database | PostgreSQL (SQL) | Firestore (NoSQL) |
| Setup | Simple | Complex |
| Queries | Full SQL power | Limited queries |
| Cost | More generous free tier | Can get expensive |
| Open Source | Yes | No |
| Self-hostable | Yes | No |

## Next Steps

1. ✅ Create Supabase project
2. ✅ Add credentials to config
3. ✅ Run SQL to create tables
4. ✅ Enable phone auth
5. ✅ Create storage bucket
6. ✅ Run `flutter pub get`
7. ✅ Test the app!

Need help? Check the [Supabase Docs](https://supabase.com/docs)
