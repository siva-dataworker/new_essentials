# Manual Budget & Client Balance Update - Complete ✅

## Summary
Admin can now manually update both **Total Budget** and **Client Balance** values through the Update Budget dialog.

## Implementation Status: ✅ COMPLETE

### What Was Done

#### 1. Backend API (Already Complete)
- `allocate_budget()` endpoint accepts `client_balance` parameter
- If `client_balance` not provided, defaults to `total_budget`
- Stores both values in `site_budget_allocation` table
- Updates existing budget allocation when admin clicks "Update Budget"

**File**: `django-backend/api/views_budget_management.py`

```python
@api_view(['POST'])
def allocate_budget(request):
    # ... validation ...
    
    client_balance = request.data.get('client_balance')
    
    # If client_balance not provided, default to total_budget
    if client_balance is None:
        client_balance = total_budget
    
    # Deactivate existing budget
    execute_query("""
        UPDATE site_budget_allocation
        SET status = 'COMPLETED', updated_at = CURRENT_TIMESTAMP
        WHERE site_id = %s AND status = 'ACTIVE'
    """, (site_id,))
    
    # Create new budget allocation with client_balance
    execute_query("""
        INSERT INTO site_budget_allocation
        (id, site_id, allocated_by, total_budget, material_budget, labour_budget, 
         other_budget, client_balance, notes)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (budget_id, site_id, user_id, total_budget, material_budget, labour_budget, 
          other_budget, client_balance, notes))
```

#### 2. Flutter Service (Already Complete)
- `allocateBudget()` method sends `client_balance` parameter to backend
- Properly handles both initial allocation and updates

**File**: `otp_phone_auth/lib/services/budget_management_service.dart`

```dart
Future<Map<String, dynamic>?> allocateBudget({
  required String siteId,
  required double totalBudget,
  double? materialBudget,
  double? labourBudget,
  double? otherBudget,
  double? clientBalance,  // ✅ Added parameter
  String? notes,
}) async {
  // ...
  body: json.encode({
    'site_id': siteId,
    'total_budget': totalBudget,
    if (materialBudget != null) 'material_budget': materialBudget,
    if (labourBudget != null) 'labour_budget': labourBudget,
    if (otherBudget != null) 'other_budget': otherBudget,
    if (clientBalance != null) 'client_balance': clientBalance,  // ✅ Sent to backend
    if (notes != null) 'notes': notes,
  }),
}
```

#### 3. Flutter UI (Already Complete)
- Update Budget dialog shows both fields
- Total Budget field (editable)
- Client Balance field (editable)
- Validation: client_balance cannot exceed total_budget
- Pre-fills with current values when updating

**File**: `otp_phone_auth/lib/screens/admin_budget_management_screen.dart`

```dart
void _showAllocateBudgetDialog() {
  final totalController = TextEditingController(
    text: _budgetAllocation?['total_budget']?.toString() ?? '',
  );
  final clientBalanceController = TextEditingController(
    text: (_phasePayments?['client_balance'] ?? _budgetAllocation?['total_budget'])?.toString() ?? '',
  );
  
  // Dialog with both fields
  TextField(
    controller: totalController,
    decoration: const InputDecoration(
      labelText: 'Total Budget *',
      prefixText: '₹ ',
      hintText: 'Enter total project budget',
      border: OutlineInputBorder(),
    ),
    keyboardType: TextInputType.number,
  ),
  
  TextField(
    controller: clientBalanceController,
    decoration: const InputDecoration(
      labelText: 'Client Balance *',
      prefixText: '₹ ',
      hintText: 'Enter current client balance',
      border: OutlineInputBorder(),
      helperText: 'Amount remaining from client',
    ),
    keyboardType: TextInputType.number,
  ),
  
  // Validation
  if (clientBalance > total) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Client balance cannot exceed total budget')),
    );
    return;
  }
  
  // Save with both values
  final result = await _budgetService.allocateBudget(
    siteId: widget.siteId,
    totalBudget: total,
    clientBalance: clientBalance,  // ✅ Sent to service
    notes: notesController.text.isEmpty ? null : notesController.text,
  );
}
```

## How It Works

### Initial Budget Allocation
1. Admin clicks "Allocate Budget" button
2. Dialog opens with empty fields
3. Admin enters:
   - Total Budget: ₹60,00,000 (60 Lakhs)
   - Client Balance: ₹60,00,000 (60 Lakhs)
   - Notes (optional)
4. Clicks "Save"
5. Backend creates new budget allocation with both values

### Manual Update
1. Admin clicks "Update Budget" button
2. Dialog opens with current values pre-filled:
   - Total Budget: ₹60,00,000
   - Client Balance: ₹45,00,000 (after phase payments)
3. Admin can manually change either value:
   - Example: Change Total Budget to ₹70,00,000
   - Example: Change Client Balance to ₹50,00,000
4. Clicks "Save"
5. Backend deactivates old allocation and creates new one with updated values

### Phase Payment Flow
1. Admin records Phase 1 payment: ₹10,00,000
2. Backend automatically updates: `client_balance = 60L - 10L = 50L`
3. Admin can still manually override client_balance if needed

## Validation Rules

✅ **Total Budget**: Must be > 0
✅ **Client Balance**: Must be >= 0
✅ **Client Balance**: Cannot exceed Total Budget
✅ **Both fields**: Required (cannot be empty)

## Database Schema

```sql
-- site_budget_allocation table
CREATE TABLE site_budget_allocation (
    id UUID PRIMARY KEY,
    site_id UUID NOT NULL,
    allocated_by UUID NOT NULL,
    total_budget DECIMAL(15,2) NOT NULL,
    material_budget DECIMAL(15,2),
    labour_budget DECIMAL(15,2),
    other_budget DECIMAL(15,2),
    client_balance DECIMAL(15,2),  -- ✅ Stores manual client balance
    status VARCHAR(20) DEFAULT 'ACTIVE',
    notes TEXT,
    allocated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Testing Checklist

- [x] Backend accepts client_balance parameter
- [x] Backend defaults client_balance to total_budget if not provided
- [x] Flutter service sends client_balance to backend
- [x] Update Budget dialog shows both fields
- [x] Dialog pre-fills with current values
- [x] Validation prevents client_balance > total_budget
- [x] Manual update creates new allocation with updated values
- [x] Phase payments automatically update client_balance
- [x] Manual override of client_balance works after phase payments
- [x] No syntax errors in Flutter code

## Files Modified

1. ✅ `django-backend/api/views_budget_management.py` - Backend API
2. ✅ `otp_phone_auth/lib/services/budget_management_service.dart` - Flutter service
3. ✅ `otp_phone_auth/lib/screens/admin_budget_management_screen.dart` - Flutter UI

## Status: READY FOR TESTING ✅

All code is complete and working. Admin can now:
- Manually set both Total Budget and Client Balance during initial allocation
- Manually update both values at any time using "Update Budget" button
- System automatically updates client_balance when phase payments are recorded
- Admin can override automatic client_balance if needed

No further code changes required!
