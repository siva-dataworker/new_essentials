# 🔄 Firebase Login with New Account

## Current Status
Currently logged in as: **sivabalan.developer@gmail.com**

## To Login with New Email

### Step 1: Logout from Current Account
```cmd
firebase logout
```

### Step 2: Login with New Account
```cmd
firebase login
```

This will:
- Open your browser
- Ask you to select/login with Google account
- Choose your new email account
- Authorize Firebase CLI

### Step 3: Verify New Login
```cmd
firebase login:list
```

This shows all logged-in accounts.

---

## Alternative: Login with Specific Account

If you want to add another account without logging out:

```cmd
firebase login:add
```

This allows multiple accounts and you can switch between them.

---

## Next Steps After Login

Once logged in with your new account:

```cmd
cd otp_phone_auth
flutterfire configure --project=construction-4a98c
```

---

**Run this now:**
```cmd
firebase logout
firebase login
```
