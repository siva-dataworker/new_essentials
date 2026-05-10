# Phase Payment System - Implementation Guide

## Overview
Implemented a 5-phase payment tracking system where admin can record client payments in phases and track the remaining client balance.

## Database Changes

### New Table: `budget_phase_payments`
```sql
CREATE TABLE budget_phase_payments (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    budget_allocation_id UUID REFERENCES site_budget_allocation(id),
    phase_number INTEGER CHECK (phase_number BETWEEN 1 AND 5),
    phase_amount DECIMAL(15, 2),
    payment_date DATE,
    recorded_by UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    UNIQUE(budget_allocation_id, phase_number)
);
```

### Updated Table: `site_budget_allocation`
- Added column: `client_balance DECIMAL(15, 2)`
- Tracks remaining balance from client

## Backend APIs

### 1. Record Phase Payment
**Endpoint**: `POST /api/budget/record-phase-payment/`

**Request Body**:
```json
{
  "site_id": "uuid",
  "phase_number": 1,
  "phase_amount": 1000000,
  "payment_date": "2026-05-08",
  "notes": "First phase payment received"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Phase 1 payment recorded successfully",
  "payment_id": "uuid",
  "new_balance": 5000000
}
```

**Logic**:
1. Validates phase number (1-5)
2. Checks if phase already recorded
3. Validates amount doesn't exceed client balance
4. Records payment in `budget_phase_payments`
5. Updates `client_balance` in `site_budget_allocation`

### 2. Get Phase Payments
**Endpoint**: `GET /api/budget/phase-payments/<site_id>/`

**Response**:
```json
{
  "total_budget": 6000000,
  "client_balance": 5000000,
  "total_received": 1000000,
  "phases": [
    {
      "id": "uuid",
      "phase_number": 1,
      "phase_amount": 1000000,
      "payment_date": "2026-05-08",
      "notes": "First phase",
      "recorded_by": "Admin Name",
      "created_at": "2026-05-08T10:00:00"
    }
  ]
}
```

## Flutter Service Methods

### BudgetManagementService

```dart
// Record phase payment
Future<Map<String, dynamic>> recordPhasePayment({
  required String siteId,
  required int phaseNumber,
  required double phaseAmount,
  String? paymentDate,
  String? notes,
});

// Get phase payments
Future<Map<String, dynamic>?> getPhasePayments(String siteId);
```

## UI Changes Required

### Allocation Tab Layout

```
┌─────────────────────────────────────┐
│ Total Budget                        │
│ ₹6.00 L                            │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Client Balance                      │
│ ₹5.00 L                            │  ← NEW
│ (Remaining from client)             │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Details                             │
│ Allocated By: Admin                 │
│ Date: 2026-02-27                    │
│ Status: ACTIVE                      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ [+] Update Budget                   │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Phase Payments                      │  ← NEW SECTION
│                                     │
│ Phase 1: ₹10.00 L  [Paid ✓]       │
│ Phase 2: ₹0        [Record Payment]│
│ Phase 3: ₹0        [Record Payment]│
│ Phase 4: ₹0        [Record Payment]│
│ Phase 5: ₹0        [Record Payment]│
└─────────────────────────────────────┘
```

### Phase Payment Dialog

When admin clicks "Record Payment" on a phase:

```
┌─────────────────────────────────────┐
│ Record Phase 2 Payment              │
│                                     │
│ Client Balance: ₹50.00 L           │
│                                     │
│ Amount *                            │
│ ₹ [____________]                   │
│                                     │
│ Payment Date                        │
│ [08/05/2026] 📅                    │
│                                     │
│ Notes (optional)                    │
│ [________________________]          │
│                                     │
│ [Cancel]  [Record Payment]          │
└─────────────────────────────────────┘
```

## Implementation Steps

### Step 1: Run Database Migration
```bash
cd essential/essential/construction_flutter/django-backend
psql -U your_user -d your_database -f add_phase_payments_table.sql
```

### Step 2: Restart Django Server
```bash
python manage.py runserver
```

### Step 3: Update Flutter UI

Add to `_AdminBudgetManagementScreenState`:

```dart
// Phase payments data
Map<String, dynamic>? _phasePayments;
bool _isLoadingPhases = false;

Future<void> _loadPhasePayments() async {
  setState(() => _isLoadingPhases = true);
  final phases = await _budgetService.getPhasePayments(widget.siteId);
  if (mounted) {
    setState(() {
      _phasePayments = phases;
      _isLoadingPhases = false;
    });
  }
}
```

Add to `_buildAllocationTab()`:

```dart
// After Update Budget button
const SizedBox(height: 24),
_buildPhasePaymentsSection(),
```

Add method:

```dart
Widget _buildPhasePaymentsSection() {
  if (_phasePayments == null) return const SizedBox.shrink();
  
  final phases = List<Map<String, dynamic>>.from(_phasePayments!['phases'] ?? []);
  final clientBalance = _phasePayments!['client_balance'] ?? 0;
  
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phase Payments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Show all 5 phases
          for (int i = 1; i <= 5; i++) ...[
            _buildPhaseRow(i, phases, clientBalance),
            if (i < 5) const Divider(),
          ],
        ],
      ),
    ),
  );
}

Widget _buildPhaseRow(int phaseNumber, List<Map<String, dynamic>> phases, double clientBalance) {
  final phase = phases.firstWhere(
    (p) => p['phase_number'] == phaseNumber,
    orElse: () => {},
  );
  
  final isPaid = phase.isNotEmpty;
  final amount = isPaid ? phase['phase_amount'] : 0.0;
  
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: isPaid ? Colors.green : Colors.grey[300],
      child: Text(
        '$phaseNumber',
        style: TextStyle(
          color: isPaid ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    title: Text('Phase $phaseNumber'),
    subtitle: isPaid 
        ? Text('Paid: ${_formatCurrency(amount)}')
        : const Text('Not paid yet'),
    trailing: isPaid
        ? const Icon(Icons.check_circle, color: Colors.green)
        : ElevatedButton(
            onPressed: () => _showRecordPhasePaymentDialog(phaseNumber, clientBalance),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
            ),
            child: const Text('Record'),
          ),
  );
}

void _showRecordPhasePaymentDialog(int phaseNumber, double clientBalance) {
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Record Phase $phaseNumber Payment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Client Balance: ${_formatCurrency(clientBalance)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text('Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter amount')),
                );
                return;
              }

              final amount = double.parse(amountController.text);
              if (amount > clientBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Amount exceeds client balance (${_formatCurrency(clientBalance)})')),
                );
                return;
              }

              final result = await _budgetService.recordPhasePayment(
                siteId: widget.siteId,
                phaseNumber: phaseNumber,
                phaseAmount: amount,
                paymentDate: '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                notes: notesController.text.isEmpty ? null : notesController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'] ?? 'Phase payment recorded')),
                  );
                  _loadPhasePayments();
                  _loadBudgetAllocation(forceRefresh: true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['error'] ?? 'Failed to record payment')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E)),
            child: const Text('Record Payment'),
          ),
        ],
      ),
    ),
  );
}
```

## User Flow

1. **Admin allocates budget**: ₹60 Lakhs
   - `total_budget` = ₹60L
   - `client_balance` = ₹60L

2. **Admin records Phase 1 payment**: ₹10 Lakhs
   - Phase 1 marked as paid
   - `client_balance` = ₹50L

3. **Admin records Phase 2 payment**: ₹15 Lakhs
   - Phase 2 marked as paid
   - `client_balance` = ₹35L

4. **And so on for remaining phases**

## Benefits

1. **Clear Payment Tracking**: See exactly which phases are paid
2. **Balance Visibility**: Always know how much client owes
3. **Payment History**: Track when each phase was paid
4. **Validation**: Prevents recording more than client balance
5. **Audit Trail**: Records who recorded each payment and when

## Files Modified

1. `django-backend/add_phase_payments_table.sql` - Database schema
2. `django-backend/api/views_budget_management.py` - Backend APIs
3. `django-backend/api/urls.py` - URL patterns
4. `otp_phone_auth/lib/services/budget_management_service.dart` - Service methods
5. `otp_phone_auth/lib/screens/admin_budget_management_screen.dart` - UI (to be updated)

## Status
Backend complete ✅
Flutter service complete ✅
Flutter UI - needs implementation (code provided above)
