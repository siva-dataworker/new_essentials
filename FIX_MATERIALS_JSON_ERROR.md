# Fix Materials JSON Error - Complete Guide

## Problem
Getting `FormatException: SyntaxError: Unexpected token '<', "<!DOCTYPE "... is not valid JSON` when clicking "Add Material Cost".

## Root Cause
The backend is returning HTML instead of JSON, which happens when:
1. The endpoint doesn't exist or isn't registered
2. The backend server hasn't been restarted after code changes
3. There's an unhandled exception in the backend

## Step-by-Step Fix

### Step 1: Test the Backend Endpoint
Run this command in the Django backend directory:
```bash
cd essential/essential/construction_flutter/django-backend
python test_materials_endpoint.py
```

This will:
- Test if the database query works
- Show you what materials exist
- Display the JSON response format

### Step 2: Restart Django Backend
**CRITICAL**: You must restart the Django server for code changes to take effect.

```bash
# Stop the current server (Ctrl+C)
# Then restart it:
python manage.py runserver
```

### Step 3: Verify the Endpoint is Accessible
Open your browser and go to:
```
http://localhost:8000/api/construction/materials/
```

You should see JSON like:
```json
{
  "materials": [
    {"id": "...", "name": "Cement", "created_at": "..."},
    {"id": "...", "name": "Steel", "created_at": "..."}
  ]
}
```

If you see HTML or an error page, the backend needs fixing.

### Step 4: Hot Restart Flutter App
After confirming the backend works:
```bash
# In your Flutter terminal, press:
r  # for hot restart
```

## Files That Were Fixed

### 1. Backend: `views_construction.py`
Added proper error handling:
```python
def get_materials(request):
    try:
        materials = fetch_all("""
            SELECT id, material_name, created_at
            FROM material_master
            ORDER BY material_name ASC
        """)
        
        response_data = {
            'materials': [
                {
                    'id': str(m['id']),
                    'name': m['material_name'],
                    'created_at': m['created_at'].isoformat() if m.get('created_at') else None
                }
                for m in materials
            ]
        }
        
        return Response(response_data, status=status.HTTP_200_OK)
    except Exception as e:
        # ✅ FIXED: Always return JSON, even on error
        return Response({'error': str(e), 'materials': []}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
```

### 2. Frontend: `budget_management_service.dart`
Added detailed logging:
```dart
Future<List<Map<String, dynamic>>> getMaterials() async {
  try {
    final token = await _authService.getToken();
    if (token == null) {
      print('❌ [MATERIALS] No auth token');
      return [];
    }

    print('🔍 [MATERIALS] Fetching from: $baseUrl/construction/materials/');
    final response = await http.get(
      Uri.parse('$baseUrl/construction/materials/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📡 [MATERIALS] Response status: ${response.statusCode}');
    print('📦 [MATERIALS] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final materials = List<Map<String, dynamic>>.from(data['materials'] ?? []);
      print('✅ [MATERIALS] Loaded ${materials.length} materials');
      return materials;
    }
    
    print('❌ [MATERIALS] Failed with status ${response.statusCode}');
    return [];
  } catch (e) {
    print('❌ [MATERIALS] Exception: $e');
    return [];
  }
}
```

### 3. Frontend: `admin_budget_management_screen.dart`
Added try-catch wrapper:
```dart
void _showAddMaterialCostDialog() async {
  try {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    // Load materials
    final materials = await _budgetService.getMaterials();
    
    // Close loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }
    
    // ... rest of dialog code
  } catch (e) {
    print('❌ Error in material dialog: $e');
    // Handle error gracefully
  }
}
```

## Debugging Steps

### Check Flutter Console
After clicking "Add Material Cost", check the Flutter console for these logs:
```
🔍 [MATERIALS] Fetching from: http://localhost:8000/api/construction/materials/
📡 [MATERIALS] Response status: 200
📦 [MATERIALS] Response body: {"materials":[...]}
✅ [MATERIALS] Loaded X materials
```

If you see:
- `❌ [MATERIALS] No auth token` → Authentication issue
- `📡 [MATERIALS] Response status: 404` → Endpoint not found
- `📡 [MATERIALS] Response status: 500` → Backend error
- `❌ [MATERIALS] Exception: ...` → Network or parsing error

### Check Django Console
You should see:
```
🔍 [MATERIALS API] Fetching materials...
🔍 [MATERIALS API] Found X materials in database
  - Cement (ID: ...)
  - Steel (ID: ...)
✅ [MATERIALS API] Returning X materials
```

## Common Issues

### Issue 1: "No materials in database"
**Solution**: Add materials first using the Admin → Manage Materials screen

### Issue 2: "Endpoint not found (404)"
**Solution**: 
1. Check `api/urls.py` has: `path('construction/materials/', views_construction.get_materials, name='get-materials')`
2. Restart Django server

### Issue 3: "Authentication failed"
**Solution**: 
1. Check if you're logged in
2. Check if token is valid
3. Try logging out and back in

### Issue 4: "Still getting HTML response"
**Solution**:
1. **MUST restart Django server** - code changes don't apply until restart
2. Clear browser cache if testing in browser
3. Check Django console for errors

## Quick Checklist
- [ ] Backend code updated in `views_construction.py`
- [ ] Django server restarted
- [ ] Endpoint accessible at `http://localhost:8000/api/construction/materials/`
- [ ] Returns valid JSON (not HTML)
- [ ] Flutter app hot restarted
- [ ] Check Flutter console for logs
- [ ] Check Django console for logs

## If Still Not Working
1. Run the test script: `python test_materials_endpoint.py`
2. Check if materials exist in database
3. Share the Flutter console logs
4. Share the Django console logs
5. Share what you see when visiting the endpoint in browser

## Status
After following these steps, the material dropdown should work with:
- ✅ "Other (Custom)" as first option
- ✅ All database materials below it
- ✅ Custom input field when "Other" selected
- ✅ No JSON errors
