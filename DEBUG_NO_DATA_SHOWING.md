# Debug Guide: Data Not Showing in History/Accountant

## Possible Causes & Solutions

### 1. ❌ NO DATA IN DATABASE (Most Likely)
**Symptom**: Empty history and accountant pages  
**Cause**: Supervisor hasn't successfully submitted any data yet

**How to Check**:
Run this in django-backend folder:
```bash
python simple_db_check.py
```

**If it shows 0 entries**, the problem is data submission is failing.

**Solution**: Check Flutter app console for errors when submitting

---

### 2. ❌ DATA SUBMISSION FAILING
**Symptom**: Submit button works but no success message or error  
**Possible Causes**:
- Backend not running
- Wrong backend URL
- Network error
- Database connection error

**How to Check Flutter Console**:
Look for these errors:
```
Error submitting labour: ...
Network error: ...
Failed to submit: ...
```

**Solutions**:
- Ensure backend is running: `python manage.py runserver 192.168.1.7:8000`
- Check Flutter console for actual error messages
- Verify backend URL in `construction_service.dart` is `http://192.168.1.7:8000/api`

---

### 3. ❌ BACKEND NOT RESTARTED
**Symptom**: Old code still running  
**Cause**: Django dev server needs restart to load new code

**Solution**:
```bash
cd django-backend
# Stop current server (Ctrl+C)
python manage.py runserver 192.168.1.7:8000
```

---

### 4. ❌ WRONG USER ID IN TOKEN
**Symptom**: Data submits but doesn't show in history  
**Cause**: JWT token has wrong user_id

**How to Check**:
Add print statement in Flutter after login:
```dart
final user = await _authService.getCurrentUser();
print('Logged in user ID: ${user?['id']}');
```

**Solution**: Logout and login again to get fresh token

---

### 5. ❌ API ENDPOINT NOT REGISTERED
**Symptom**: 404 error when calling history API  
**Cause**: URL not added to urls.py

**How to Check**:
Look at Flutter console for:
```
404 Not Found
/api/construction/supervisor/history/
```

**Solution**: Verify urls.py has these routes (already added):
```python
path('construction/supervisor/history/', views_construction.get_supervisor_history),
path('construction/accountant/all-entries/', views_construction.get_all_entries_for_accountant),
```

---

## 🔍 STEP-BY-STEP DEBUGGING

### Step 1: Verify Backend is Running
```bash
# In django-backend folder
python manage.py runserver 192.168.1.7:8000
```

Expected output:
```
Starting development server at http://192.168.1.7:8000/
```

### Step 2: Test Login API Directly
Open browser or Postman:
```
POST http://192.168.1.7:8000/api/auth/login/
Body: {"username": "nsjskakaka", "password": "Test123"}
```

Should return token and user info.

### Step 3: Submit Data from Flutter App
1. Login as supervisor
2. Select a site
3. Tap + button
4. Add labour (e.g., Carpenter: 2)
5. Submit
6. **WATCH FLUTTER CONSOLE** for errors

### Step 4: Check if Data Saved
Run in django-backend:
```bash
python simple_db_check.py
```

Should show count > 0 if data saved.

### Step 5: Test History API
If data exists, test API directly:
```
GET http://192.168.1.7:8000/api/construction/supervisor/history/
Header: Authorization: Bearer <your-token>
```

Should return labour_entries and material_entries arrays.

---

## 🐛 COMMON ERROR MESSAGES

### Error: "Connection refused"
**Cause**: Backend not running  
**Solution**: Start backend

### Error: "401 Unauthorized"
**Cause**: Invalid or expired token  
**Solution**: Logout and login again

### Error: "500 Internal Server Error"
**Cause**: Backend code error  
**Solution**: Check Django console for Python traceback

### Error: "No data" but submission succeeded
**Cause**: Data saved but API query is wrong  
**Solution**: Check backend logs for SQL errors

---

## 📝 ADD DEBUG LOGGING

### In Flutter (construction_service.dart)
Add print statements:
```dart
Future<Map<String, dynamic>> getSupervisorHistory() async {
  print('🔍 Calling supervisor history API...');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/construction/supervisor/history/'),
      headers: await _getHeaders(),
    );
    
    print('📊 Response status: ${response.statusCode}');
    print('📊 Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Labour entries: ${data['labour_entries']?.length ?? 0}');
      print('✅ Material entries: ${data['material_entries']?.length ?? 0}');
      return data;
    }
    return {'labour_entries': [], 'material_entries': []};
  } catch (e) {
    print('❌ Error getting history: $e');
    return {'labour_entries': [], 'material_entries': []};
  }
}
```

### In Django (views_construction.py)
Add print statements:
```python
def get_supervisor_history(request):
    try:
        user_id = request.user['user_id']
        print(f"🔍 Getting history for user: {user_id}")
        
        labour_entries = fetch_all(labour_query, (user_id,))
        print(f"📊 Found {len(labour_entries)} labour entries")
        
        material_entries = fetch_all(material_query, (user_id,))
        print(f"📊 Found {len(material_entries)} material entries")
        
        return Response({...})
    except Exception as e:
        print(f"❌ Error: {e}")
        return Response({'error': str(e)}, status=500)
```

---

## ✅ VERIFICATION CHECKLIST

Run through this checklist:

- [ ] Backend is running on 192.168.1.7:8000
- [ ] Can login successfully (check Flutter console)
- [ ] Can see sites in feed
- [ ] Can open site detail page
- [ ] Can tap + button and see labour entry sheet
- [ ] Can add labour counts (e.g., Carpenter: 2)
- [ ] Can tap Submit button
- [ ] See confirmation dialog
- [ ] Tap Confirm in dialog
- [ ] See success message (green snackbar)
- [ ] **Check Flutter console for any errors**
- [ ] **Check Django console for any errors**
- [ ] Tap History tab
- [ ] **Check Flutter console for API call logs**
- [ ] **Check Django console for API request logs**

---

## 🎯 MOST LIKELY ISSUE

Based on the symptoms, the most likely cause is:

**DATA IS NOT BEING SAVED TO DATABASE**

This means the submission is failing silently. To confirm:

1. Add print statements in Flutter `submitLabourCount()` method
2. Watch console when you submit
3. Look for error messages
4. Check if you see "✅ Labour count submitted" or an error

If you see an error, that's the root cause. Common errors:
- Network timeout
- Backend not responding
- Database connection failed
- SQL constraint violation

---

## 🚀 QUICK FIX TO TRY

1. **Stop Django backend** (Ctrl+C)
2. **Restart it**:
   ```bash
   cd django-backend
   python manage.py runserver 192.168.1.7:8000
   ```
3. **Hot restart Flutter app** (press 'r' in terminal or hot restart button)
4. **Try submitting data again**
5. **Watch BOTH consoles** (Flutter and Django) for errors

If you see errors in either console, share them and I can help fix the specific issue.
