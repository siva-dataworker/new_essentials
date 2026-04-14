# 📅 Day-Based History - Step 2 Implementation Guide

## Overview
This guide shows how to complete the remaining implementation steps for the day-based history with time restrictions feature.

---

## Step 2A: Update Labour Entry Creation

### File: `django-backend/api/views_construction.py`

Find the `submit_labour_count()` function (around line 150) and update it:

```python
@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def submit_labour_count(request):
    """
    Supervisor: Submit daily labour count (morning)
    TIME RESTRICTION: Can only submit between 8 AM - 1 PM IST
    DAILY RESTRICTION: Can only submit once per day per site
    """
    try:
        # Import time utilities
        from .time_utils import is_within_entry_hours, get_entry_metadata, get_entry_time_status
        
        # CHECK TIME RESTRICTION FIRST
        if not is_within_entry_hours():
            time_status = get_entry_time_status()
            return Response({
                'error': 'Entry not allowed at this time',
                'message': time_status['message'],
                'allowed_hours': '8:00 AM - 1:00 PM IST',
                'current_time_ist': time_status['current_time_ist'],
                'next_window': time_status.get('next_window', 'tomorrow at 8:00 AM')
            }, status=status.HTTP_403_FORBIDDEN)
        
        user_id = request.user['user_id']
        site_id = request.data.get('site_id')
        labour_count = request.data.get('labour_count')
        labour_type = request.data.get('labour_type', 'General')
        notes = request.data.get('notes', '')
        extra_cost = request.data.get('extra_cost', 0)
        extra_cost_notes = request.data.get('extra_cost_notes', '')
        
        if not all([site_id, labour_count is not None]):
            return Response({'error': 'site_id and labour_count are required'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        # Get entry metadata (includes day_of_week, date, time in IST)
        entry_meta = get_entry_metadata()
        day_of_week = entry_meta['day_of_week']
        today = entry_meta['entry_date']
        now_ist = entry_meta['timestamp_ist']
        
        # DAILY RESTRICTION: Check if already submitted today for this site AND labour type
        existing_entry = fetch_one("""
            SELECT id FROM labour_entries
            WHERE supervisor_id = %s AND site_id = %s AND entry_date = %s AND labour_type = %s
        """, (user_id, site_id, today, labour_type))
        
        if existing_entry:
            return Response({
                'error': f'{labour_type} labour count already submitted today for this site. You can only submit each labour type once per day.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Insert labour entry with day_of_week
        entry_id = str(uuid.uuid4())
        execute_query("""
            INSERT INTO labour_entries 
            (id, site_id, supervisor_id, labour_count, labour_type, entry_date, entry_time, day_of_week, notes, extra_cost, extra_cost_notes)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (entry_id, site_id, user_id, labour_count, labour_type, today, now_ist, day_of_week, notes, extra_cost, extra_cost_notes))
        
        return Response({
            'message': 'Labour count submitted successfully',
            'entry_id': entry_id,
            'day_of_week': day_of_week,
            'entry_date': today.strftime('%Y-%m-%d'),
            'extra_cost': extra_cost,
            'restriction_note': 'You can only submit labour count once per day per site'
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
```

---

## Step 2B: Update Material Entry Creation

Find the `submit_material_balance()` function and update it similarly:

```python
@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def submit_material_balance(request):
    """
    Supervisor: Submit material balance (evening) with extra costs
    TIME RESTRICTION: Can only submit between 8 AM - 1 PM IST
    DAILY RESTRICTION: Can only submit once per day per site
    """
    try:
        # Import time utilities
        from .time_utils import is_within_entry_hours, get_entry_metadata, get_entry_time_status
        
        # CHECK TIME RESTRICTION FIRST
        if not is_within_entry_hours():
            time_status = get_entry_time_status()
            return Response({
                'error': 'Entry not allowed at this time',
                'message': time_status['message'],
                'allowed_hours': '8:00 AM - 1:00 PM IST',
                'current_time_ist': time_status['current_time_ist'],
                'next_window': time_status.get('next_window', 'tomorrow at 8:00 AM')
            }, status=status.HTTP_403_FORBIDDEN)
        
        user_id = request.user['user_id']
        site_id = request.data.get('site_id')
        materials = request.data.get('materials', [])
        extra_cost = request.data.get('extra_cost', 0)
        extra_cost_notes = request.data.get('extra_cost_notes', '')
        
        if not site_id or not materials:
            return Response({'error': 'site_id and materials are required'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        # Get entry metadata
        entry_meta = get_entry_metadata()
        day_of_week = entry_meta['day_of_week']
        today = entry_meta['entry_date']
        now_ist = entry_meta['timestamp_ist']
        
        # DAILY RESTRICTION: Check if already submitted today for this site
        existing_entry = fetch_one("""
            SELECT id FROM material_balances
            WHERE supervisor_id = %s AND site_id = %s AND entry_date = %s
            LIMIT 1
        """, (user_id, site_id, today))
        
        if existing_entry:
            return Response({
                'error': 'Material balance already submitted today for this site. You can only submit once per day.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Insert material balances with day_of_week
        for material in materials:
            material_id = str(uuid.uuid4())
            execute_query("""
                INSERT INTO material_balances 
                (id, site_id, supervisor_id, material_type, quantity, unit, entry_date, updated_at, day_of_week, notes, extra_cost, extra_cost_notes)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (material_id, site_id, user_id, material['material_type'], material['quantity'], 
                  material.get('unit', 'units'), today, now_ist, day_of_week, material.get('notes', ''), extra_cost, extra_cost_notes))
        
        return Response({
            'message': 'Material balance submitted successfully',
            'day_of_week': day_of_week,
            'entry_date': today.strftime('%Y-%m-%d'),
            'materials_count': len(materials),
            'extra_cost': extra_cost
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
```

---

## Step 3: Create History by Day Endpoint

Add this new function to `views_construction.py`:

```python
@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_history_by_day(request):
    """
    Get labour and material history grouped by day of week
    GET /api/construction/history-by-day/?site_id=xxx
    
    Returns entries grouped by day (Monday, Tuesday, etc.)
    """
    try:
        site_id = request.GET.get('site_id')
        user_role = request.user.get('role', '')
        user_id = request.user['user_id']
        
        if not site_id:
            return Response({'error': 'site_id is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Define day order for sorting
        day_order = {
            'Monday': 1, 'Tuesday': 2, 'Wednesday': 3, 'Thursday': 4,
            'Friday': 5, 'Saturday': 6, 'Sunday': 7
        }
        
        # Get labour entries grouped by day
        labour_query = """
            SELECT 
                l.id, l.labour_type, l.labour_count, l.entry_date, l.entry_time,
                l.day_of_week, l.notes, l.extra_cost, l.extra_cost_notes,
                l.is_modified, l.modified_at, l.modification_reason,
                s.site_name, s.area, s.street,
                u.full_name as supervisor_name
            FROM labour_entries l
            JOIN sites s ON l.site_id = s.id
            JOIN users u ON l.supervisor_id = u.id
            WHERE l.site_id = %s
        """
        
        # Add role-based filtering
        if user_role == 'Supervisor':
            labour_query += " AND l.supervisor_id = %s"
            labour_entries = fetch_all(labour_query + " ORDER BY l.entry_date DESC, l.entry_time DESC", (site_id, user_id))
        else:
            labour_entries = fetch_all(labour_query + " ORDER BY l.entry_date DESC, l.entry_time DESC", (site_id,))
        
        # Get material entries grouped by day
        material_query = """
            SELECT 
                m.id, m.material_type, m.quantity, m.unit, m.entry_date, m.updated_at,
                m.day_of_week, m.notes, m.extra_cost, m.extra_cost_notes,
                s.site_name, s.area, s.street,
                u.full_name as supervisor_name
            FROM material_balances m
            JOIN sites s ON m.site_id = s.id
            JOIN users u ON m.supervisor_id = u.id
            WHERE m.site_id = %s
        """
        
        if user_role == 'Supervisor':
            material_query += " AND m.supervisor_id = %s"
            material_entries = fetch_all(material_query + " ORDER BY m.entry_date DESC, m.updated_at DESC", (site_id, user_id))
        else:
            material_entries = fetch_all(material_query + " ORDER BY m.entry_date DESC, m.updated_at DESC", (site_id,))
        
        # Group by day_of_week
        labour_by_day = {}
        for entry in labour_entries:
            day = entry['day_of_week'] or 'Unknown'
            if day not in labour_by_day:
                labour_by_day[day] = []
            labour_by_day[day].append(entry)
        
        material_by_day = {}
        for entry in material_entries:
            day = entry['day_of_week'] or 'Unknown'
            if day not in material_by_day:
                material_by_day[day] = []
            material_by_day[day].append(entry)
        
        # Sort days
        sorted_labour_days = sorted(labour_by_day.keys(), key=lambda x: day_order.get(x, 99))
        sorted_material_days = sorted(material_by_day.keys(), key=lambda x: day_order.get(x, 99))
        
        return Response({
            'success': True,
            'site_id': site_id,
            'labour_by_day': {day: labour_by_day[day] for day in sorted_labour_days},
            'material_by_day': {day: material_by_day[day] for day in sorted_material_days},
            'total_labour_entries': len(labour_entries),
            'total_material_entries': len(material_entries)
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
```

---

## Step 4: Add URL for History by Day

In `django-backend/api/urls.py`, add:

```python
# In the construction endpoints section, add:
path('construction/history-by-day/', views_construction.get_history_by_day, name='history-by-day'),
```

---

## Step 5: Test Backend Changes

### 5.1 Restart Backend
```bash
cd django-backend
python manage.py runserver 0.0.0.0:8000
```

### 5.2 Test Time Validation
Try to submit an entry outside 8 AM - 1 PM and verify you get an error.

### 5.3 Test History by Day
```bash
curl http://localhost:8000/api/construction/history-by-day/?site_id=YOUR_SITE_ID \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Step 6: Flutter Frontend Implementation

### 6.1 Create Time Validation Service

Create `otp_phone_auth/lib/services/time_validation_service.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class TimeValidationService {
  static const String baseUrl = 'http://192.168.1.7:8000/api';
  final _authService = AuthService();
  
  Future<Map<String, dynamic>> validateEntryTime() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/construction/validate-entry-time/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      
      return {
        'allowed': false,
        'message': 'Could not validate time'
      };
    } catch (e) {
      print('Error validating time: $e');
      return {
        'allowed': false,
        'message': 'Error checking entry time'
      };
    }
  }
  
  Future<bool> isWithinAllowedHours() async {
    final result = await validateEntryTime();
    return result['allowed'] == true;
  }
  
  Future<void> showTimeRestrictionDialog(BuildContext context, Map<String, dynamic> timeStatus) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entry Not Allowed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(timeStatus['message'] ?? 'Entries only allowed 8 AM - 1 PM IST'),
            const SizedBox(height: 16),
            Text('Current time: ${timeStatus['current_time_ist'] ?? 'Unknown'}'),
            if (timeStatus['next_window'] != null) ...[
              const SizedBox(height: 8),
              Text('Next window: ${timeStatus['next_window']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

### 6.2 Update Supervisor Entry Forms

Before showing entry forms, check time:

```dart
final timeService = TimeValidationService();
final timeStatus = await timeService.validateEntryTime();

if (!timeStatus['allowed']) {
  await timeService.showTimeRestrictionDialog(context, timeStatus);
  return;
}

// Show entry form
```

---

## Summary

**Backend Changes**:
1. ✅ Update `submit_labour_count()` - Add time check, store day_of_week
2. ✅ Update `submit_material_balance()` - Add time check, store day_of_week
3. ✅ Create `get_history_by_day()` - New endpoint for day-based history
4. ✅ Add URL route for history by day

**Frontend Changes**:
1. ✅ Create `TimeValidationService`
2. ✅ Add time checks before entry forms
3. ⏳ Update history display (next step)
4. ⏳ Update accountant view (next step)

**Testing**:
- Test time restriction (try outside 8 AM - 1 PM)
- Test day_of_week storage
- Test history by day endpoint
- Test Flutter time validation

---

**Status**: Ready to implement! Follow this guide step by step.
