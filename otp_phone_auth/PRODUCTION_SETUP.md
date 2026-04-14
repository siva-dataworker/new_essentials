# Production Setup Guide - Real SMS OTP

## 💳 Upgrade to Blaze Plan

### Why Upgrade?
- Test phone numbers are free but limited
- Real SMS requires Blaze (pay-as-you-go) plan
- First 10,000 verifications/month are FREE

### How to Upgrade

1. **Open Firebase Console:**
   https://console.firebase.google.com/project/constructionsite-8d964/overview

2. **Click "Upgrade" button** (bottom left or top right)

3. **Select "Blaze Plan"**

4. **Add Payment Method:**
   - Credit/Debit card
   - Google Cloud billing account

5. **Confirm and Activate**

## 💰 Pricing Breakdown

### Phone Authentication Costs

| Usage | Cost |
|-------|------|
| 0 - 10,000 verifications/month | **FREE** |
| 10,001+ verifications/month | $0.01 per verification |

### SMS Delivery Costs (by Country)

| Country | Cost per SMS |
|---------|--------------|
| USA | ~$0.01 |
| Canada | ~$0.01 |
| UK | ~$0.02 |
| India | ~$0.02 |
| Australia | ~$0.03 |
| Other | Varies |

### Example Monthly Costs

| Monthly Users | Verifications | Cost |
|---------------|---------------|------|
| 100 | 100 | **$0** (Free tier) |
| 1,000 | 1,000 | **$0** (Free tier) |
| 5,000 | 5,000 | **$0** (Free tier) |
| 10,000 | 10,000 | **$0** (Free tier) |
| 15,000 | 15,000 | **$50** |
| 25,000 | 25,000 | **$150** |
| 50,000 | 50,000 | **$400** |

## 🔐 Security Setup (Important!)

### 1. Enable App Check (Highly Recommended)

Prevents abuse and unauthorized access:

1. Go to Firebase Console → App Check
2. Enable for your Android app
3. Select provider: **Play Integrity** (for Android)
4. Add to your app:

```yaml
# pubspec.yaml
dependencies:
  firebase_app_check: ^0.3.1+3
```

```dart
// lib/main.dart
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  
  runApp(const MyApp());
}
```

### 2. Set Rate Limits

In Firebase Console → Authentication → Settings:

- **Maximum SMS per hour per IP:** 5-10
- **Maximum SMS per day per phone:** 3-5
- **Block suspicious activity:** Enable

### 3. Implement Client-Side Rate Limiting

```dart
// Add to phone_auth_screen.dart
class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  DateTime? _lastOtpSentTime;
  static const _otpCooldown = Duration(seconds: 60);

  Future<void> _sendOTP() async {
    // Check cooldown
    if (_lastOtpSentTime != null) {
      final timeSinceLastOtp = DateTime.now().difference(_lastOtpSentTime!);
      if (timeSinceLastOtp < _otpCooldown) {
        final remainingSeconds = _otpCooldown.inSeconds - timeSinceLastOtp.inSeconds;
        _showErrorDialog('Please wait $remainingSeconds seconds before requesting another OTP');
        return;
      }
    }

    // ... existing OTP sending code ...
    
    // Update last sent time
    _lastOtpSentTime = DateTime.now();
  }
}
```

### 4. Monitor Usage

Set up budget alerts:

1. Firebase Console → Settings → Usage and billing
2. Set alerts at:
   - $10 (warning)
   - $50 (alert)
   - $100 (critical)
   - $500 (maximum)

### 5. Add reCAPTCHA (Web Only)

For web apps, Firebase automatically uses reCAPTCHA to prevent abuse.

## 📊 Cost Optimization Tips

### 1. Use Test Numbers During Development
```dart
// Keep test numbers for development
// Phone: +1 650 555 1234
// Code: 123456
```

### 2. Implement Phone Number Validation
```dart
bool isValidPhoneNumber(String phone) {
  // Add your validation logic
  return phone.length >= 10 && phone.startsWith('+');
}
```

### 3. Cache Verification Results
```dart
// Store verified numbers locally
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setBool('phone_verified', true);
```

### 4. Add Confirmation Dialog
```dart
Future<void> _sendOTP() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Send OTP?'),
      content: Text('An SMS will be sent to $_completePhoneNumber'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Send'),
        ),
      ],
    ),
  );
  
  if (confirm == true) {
    // Send OTP
  }
}
```

## 🚀 Deployment Checklist

Before going live with real SMS:

- [ ] Upgraded to Blaze plan
- [ ] Payment method added
- [ ] Budget alerts configured
- [ ] App Check enabled
- [ ] Rate limiting implemented
- [ ] Phone validation added
- [ ] Error handling tested
- [ ] SHA-1 certificate added (release + debug)
- [ ] Tested with real phone numbers
- [ ] Monitoring dashboard set up

## 🔄 Switching Between Test and Production

### Development (Test Numbers)
```dart
// Use test numbers in Firebase Console
// No SMS sent, instant verification
// FREE
```

### Production (Real SMS)
```dart
// Same code works automatically
// Real SMS sent
// Costs apply after 10K/month
```

### Environment-Based Configuration
```dart
class Config {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
  
  static String getTestPhone() {
    return isProduction ? '' : '+1 650 555 1234';
  }
  
  static String getTestCode() {
    return isProduction ? '' : '123456';
  }
}
```

## 📱 Testing Real SMS

### Step 1: Upgrade Plan
Complete the Blaze plan upgrade

### Step 2: Test with Your Number
1. Run the app
2. Enter your real phone number
3. Click "Send OTP"
4. Check your phone for SMS
5. Enter the code
6. Verify success

### Step 3: Monitor Costs
Check Firebase Console → Usage and billing

## 🆘 Troubleshooting

### SMS Not Received
1. Check Firebase billing is active
2. Verify phone number format (+country code)
3. Check spam/blocked messages
4. Try different phone number
5. Check Firebase quota limits

### High Costs
1. Check for abuse/bot traffic
2. Enable App Check
3. Implement rate limiting
4. Review authentication logs
5. Set stricter budget alerts

### Quota Exceeded
1. Check current usage in Firebase Console
2. Increase quota or wait for reset
3. Implement better rate limiting

## 💡 Best Practices

1. **Always use test numbers during development**
2. **Enable App Check before production**
3. **Set budget alerts immediately**
4. **Monitor usage weekly**
5. **Implement client-side rate limiting**
6. **Add phone number validation**
7. **Log all authentication attempts**
8. **Review costs monthly**

## 📞 Support

- **Firebase Pricing:** https://firebase.google.com/pricing
- **Phone Auth Docs:** https://firebase.google.com/docs/auth/flutter/phone-auth
- **App Check:** https://firebase.google.com/docs/app-check

---

**Ready to go live?** Upgrade to Blaze plan and start sending real SMS! 🚀
