# Budget Utilization - Add Costs & Enhanced Filtering

## 📋 Overview

This document describes the implementation of:
1. **Add Cost Button (+)** - Add Material or Other costs directly from Utilization screen
2. **Material Cost Entry** - Select material type, quantity, unit, and amount
3. **Other Cost Entry** - Enter cost type and amount
4. **Enhanced Filtering** - Filter by Material, Labour, or Other costs
5. **Auto-calculation** - Costs automatically reflected in utilization

## ✨ Features

### 1. Add Cost Button (+)
- Floating action button in Utilization tab
- Opens dialog with two options:
  - **Add Material Cost**
  - **Add Other Cost**

### 2. Material Cost Entry Dialog
**Fields:**
- Material Type (dropdown or text input)
- Quantity (number)
- Unit (dropdown: bags, tons, cubic meters, pieces, etc.)
- Unit Cost (₹)
- Total Cost (auto-calculated: quantity × unit cost)
- Entry Date (date picker, defaults to today)
- Notes (optional)

**Validation:**
- All fields except notes are required
- Quantity must be positive
- Unit cost must be positive
- Total cost auto-calculates

### 3. Other Cost Entry Dialog
**Fields:**
- Cost Type (dropdown: Transport, Equipment Rental, Services, Utilities, Other)
- Description (text)
- Amount (₹)
- Entry Date (date picker, defaults to today)
- Notes (optional)

**Validation:**
- Cost type and amount are required
- Amount must be positive

### 4. Enhanced Filter Options
**Filter Types:**
- **All** (default) - Shows all costs
- **Material** - Shows only material costs
- **Labour** - Shows only labour costs
- **Other** - Shows only other costs

**Filter UI:**
- Dropdown or chip selector
- Combined with date filter
- Clear button to reset filters

### 5. Auto-calculation
- Costs immediately reflected in Total Spent
- Breakdown sections update automatically
- Utilization percentage recalculates
- Cache invalidated on new entry

## 🔧 Implementation

### Backend APIs

#### 1. Add Material Cost
```python
POST /api/budget/add-material-cost/

Request Body:
{
  "site_id": "uuid",
  "material_type": "Cement",
  "quantity": 50,
  "unit": "bags",
  "unit_cost": 400,
  "total_cost": 20000,
  "entry_date": "2026-05-08",
  "notes": "Purchased from XYZ Suppliers"
}

Response:
{
  "success": true,
  "message": "Material cost added successfully",
  "cost_id": "uuid"
}
```

**Database Table:** `material_cost_tracking`
```sql
INSERT INTO material_cost_tracking
(id, site_id, material_type, quantity, unit, unit_cost, total_cost, 
 recorded_by, recorded_date, notes, created_at)
VALUES (...)
```

#### 2. Add Other Cost
```python
POST /api/budget/add-other-cost/

Request Body:
{
  "site_id": "uuid",
  "cost_type": "Transport",
  "description": "Material transport from warehouse",
  "amount": 5000,
  "entry_date": "2026-05-08",
  "notes": "Truck rental for 2 days"
}

Response:
{
  "success": true,
  "message": "Other cost added successfully",
  "bill_id": "uuid"
}
```

**Database Table:** `vendor_bills`
```sql
INSERT INTO vendor_bills
(id, site_id, uploaded_by, bill_number, bill_date, vendor_name, vendor_type,
 service_type, service_description, amount, final_amount, payment_status, 
 file_url, file_name, notes, upload_date, day_of_week, is_active, created_at)
VALUES (...)
```

#### 3. Enhanced Get Budget Utilization
```python
GET /api/budget/utilization/{site_id}/?date=YYYY-MM-DD&filter=material|labour|other

Query Parameters:
- date (optional): Filter labour by specific date
- filter (optional): Filter by cost type (material, labour, other, or empty for all)

Response:
{
  "summary": {
    "total_budget": 600000,
    "total_material_cost": 50000,
    "total_labour_cost": 30000,
    "total_vendor_cost": 10000,
    "total_spent": 90000,  // Filtered based on filter parameter
    "remaining_budget": 510000,
    "utilization_percentage": 15.0,
    "filter_active": true,
    "filter_type": "material",  // or "labour", "other", "all"
    "filter_date": "2026-05-08"
  },
  "material_breakdown": [...],  // Empty if filter != "material" and filter != "all"
  "labour_breakdown": [...],    // Empty if filter != "labour" and filter != "all"
  "other_breakdown": [...]      // Empty if filter != "other" and filter != "all"
}
```

### Flutter Service Methods

#### File: `budget_management_service.dart`

```dart
/// Add material cost entry
Future<Map<String, dynamic>> addMaterialCost({
  required String siteId,
  required String materialType,
  required double quantity,
  required String unit,
  required double unitCost,
  required double totalCost,
  String? entryDate,
  String? notes,
}) async {
  // Implementation provided in code
}

/// Add other cost entry
Future<Map<String, dynamic>> addOtherCost({
  required String siteId,
  required String costType,
  String? description,
  required double amount,
  String? entryDate,
  String? notes,
}) async {
  // Implementation provided in code
}

/// Get budget utilization with filters
Future<Map<String, dynamic>?> getBudgetUtilization(
  String siteId, 
  {String? filterDate, String? filterType}
) async {
  // Build URL with optional filters
  String url = '$baseUrl/budget/utilization/$siteId/';
  List<String> params = [];
  
  if (filterDate != null && filterDate.isNotEmpty) {
    params.add('date=$filterDate');
  }
  
  if (filterType != null && filterType.isNotEmpty) {
    params.add('filter=$filterType');
  }
  
  if (params.isNotEmpty) {
    url += '?${params.join('&')}';
  }
  
  // Make API call
}
```

### Flutter UI Updates

#### File: `admin_budget_management_screen.dart`

**1. Add State Variables:**
```dart
String? _selectedCostFilter; // 'material', 'labour', 'other', or null for all
```

**2. Add Floating Action Button:**
```dart
floatingActionButton: FloatingActionButton(
  onPressed: _showAddCostDialog,
  backgroundColor: const Color(0xFF1A1A2E),
  child: const Icon(Icons.add, color: Colors.white),
  tooltip: 'Add Cost',
)
```

**3. Add Cost Dialog:**
```dart
void _showAddCostDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Cost'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.inventory_2, color: Colors.brown),
            title: const Text('Add Material Cost'),
            onTap: () {
              Navigator.pop(context);
              _showAddMaterialCostDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money, color: Colors.purple),
            title: const Text('Add Other Cost'),
            onTap: () {
              Navigator.pop(context);
              _showAddOtherCostDialog();
            },
          ),
        ],
      ),
    ),
  );
}
```

**4. Material Cost Dialog:**
```dart
void _showAddMaterialCostDialog() {
  final materialTypeController = TextEditingController();
  final quantityController = TextEditingController();
  final unitController = TextEditingController(text: 'bags');
  final unitCostController = TextEditingController();
  final totalCostController = TextEditingController();
  final notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  // Auto-calculate total cost
  void calculateTotal() {
    final qty = double.tryParse(quantityController.text) ?? 0;
    final cost = double.tryParse(unitCostController.text) ?? 0;
    totalCostController.text = (qty * cost).toStringAsFixed(2);
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Material Cost'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: materialTypeController,
              decoration: const InputDecoration(
                labelText: 'Material Type *',
                hintText: 'e.g., Cement, Steel, Bricks',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity *'),
              keyboardType: TextInputType.number,
              onChanged: (_) => calculateTotal(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: unitController.text,
              decoration: const InputDecoration(labelText: 'Unit *'),
              items: ['bags', 'tons', 'cubic meters', 'pieces', 'kg', 'liters']
                  .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                  .toList(),
              onChanged: (value) => unitController.text = value ?? 'bags',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitCostController,
              decoration: const InputDecoration(
                labelText: 'Unit Cost *',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => calculateTotal(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: totalCostController,
              decoration: const InputDecoration(
                labelText: 'Total Cost',
                prefixText: '₹ ',
              ),
              readOnly: true,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text('Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  selectedDate = picked;
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
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
            // Validation
            if (materialTypeController.text.isEmpty ||
                quantityController.text.isEmpty ||
                unitCostController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all required fields')),
              );
              return;
            }

            // Add material cost
            final result = await _budgetService.addMaterialCost(
              siteId: widget.siteId,
              materialType: materialTypeController.text,
              quantity: double.parse(quantityController.text),
              unit: unitController.text,
              unitCost: double.parse(unitCostController.text),
              totalCost: double.parse(totalCostController.text),
              entryDate: '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
              notes: notesController.text.isEmpty ? null : notesController.text,
            );

            if (context.mounted) {
              Navigator.pop(context);
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'] ?? 'Material cost added')),
                );
                // Reload utilization
                _loadUtilization(forceRefresh: true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['error'] ?? 'Failed to add material cost')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E)),
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
```

**5. Other Cost Dialog:**
```dart
void _showAddOtherCostDialog() {
  final costTypeController = TextEditingController(text: 'Transport');
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Other Cost'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: costTypeController.text,
              decoration: const InputDecoration(labelText: 'Cost Type *'),
              items: ['Transport', 'Equipment Rental', 'Services', 'Utilities', 'Other']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => costTypeController.text = value ?? 'Transport',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of the cost',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount *',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text('Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  selectedDate = picked;
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
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
            // Validation
            if (amountController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter amount')),
              );
              return;
            }

            // Add other cost
            final result = await _budgetService.addOtherCost(
              siteId: widget.siteId,
              costType: costTypeController.text,
              description: descriptionController.text.isEmpty ? null : descriptionController.text,
              amount: double.parse(amountController.text),
              entryDate: '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
              notes: notesController.text.isEmpty ? null : notesController.text,
            );

            if (context.mounted) {
              Navigator.pop(context);
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'] ?? 'Other cost added')),
                );
                // Reload utilization
                _loadUtilization(forceRefresh: true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['error'] ?? 'Failed to add other cost')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E)),
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
```

**6. Enhanced Filter UI:**
```dart
// Add to filter card
Row(
  children: [
    // Existing date filter
    Expanded(
      child: DropdownButton<String>(
        value: _selectedCostFilter,
        hint: const Text('All Costs'),
        items: [
          const DropdownMenuItem(value: null, child: Text('All')),
          const DropdownMenuItem(value: 'material', child: Text('Material')),
          const DropdownMenuItem(value: 'labour', child: Text('Labour')),
          const DropdownMenuItem(value: 'other', child: Text('Other')),
        ],
        onChanged: (value) {
          setState(() {
            _selectedCostFilter = value;
          });
          _loadUtilization(forceRefresh: true);
        },
      ),
    ),
  ],
)
```

**7. Update Load Utilization:**
```dart
Future<void> _loadUtilization({bool forceRefresh = false}) async {
  setState(() => _isLoadingUtilization = true);
  
  // Format date for API if filter is active
  String? filterDate;
  if (_isFilterActive && _selectedFilterDate != null) {
    filterDate = '${_selectedFilterDate!.year}-${_selectedFilterDate!.month.toString().padLeft(2, '0')}-${_selectedFilterDate!.day.toString().padLeft(2, '0')}';
  }
  
  final utilization = await _budgetService.getBudgetUtilization(
    widget.siteId, 
    filterDate: filterDate,
    filterType: _selectedCostFilter,
  );
  
  if (mounted) {
    setState(() {
      _utilization = utilization;
      _isLoadingUtilization = false;
    });
  }
}
```

**8. Display Other Costs Breakdown:**
```dart
// Add after Labour Breakdown
if ((List<Map<String, dynamic>>.from(_utilization!['other_breakdown'] ?? [])).isNotEmpty) ...[
  const Text('Other Costs Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  const SizedBox(height: 8),
  ...(List<Map<String, dynamic>>.from(_utilization!['other_breakdown'] ?? [])).map((o) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.attach_money, color: Colors.purple),
          title: Text(o['service_type'] ?? 'Unknown'),
          subtitle: Text(o['vendor_type'] ?? ''),
          trailing: Text(_formatCurrency(o['total_cost']), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      )),
],
```

## 📊 User Flow

### Add Material Cost
```
1. Admin opens Budget Utilization tab
2. Clicks + button (FAB)
3. Selects "Add Material Cost"
4. Fills form:
   - Material Type: Cement
   - Quantity: 50
   - Unit: bags
   - Unit Cost: ₹400
   - Total Cost: ₹20,000 (auto-calculated)
   - Date: Today
   - Notes: (optional)
5. Clicks "Add"
6. Success message shown
7. Utilization reloads automatically
8. Material cost appears in breakdown
9. Total Spent increases by ₹20,000
```

### Add Other Cost
```
1. Admin opens Budget Utilization tab
2. Clicks + button (FAB)
3. Selects "Add Other Cost"
4. Fills form:
   - Cost Type: Transport
   - Description: Material delivery
   - Amount: ₹5,000
   - Date: Today
   - Notes: (optional)
5. Clicks "Add"
6. Success message shown
7. Utilization reloads automatically
8. Other cost appears in breakdown
9. Total Spent increases by ₹5,000
```

### Filter by Cost Type
```
1. Admin opens Budget Utilization tab
2. Selects filter: "Material"
3. View updates to show:
   - Total Spent: Only material costs
   - Material Breakdown: All materials
   - Labour Breakdown: Hidden
   - Other Breakdown: Hidden
4. Selects filter: "Labour"
5. View updates to show:
   - Total Spent: Only labour costs
   - Material Breakdown: Hidden
   - Labour Breakdown: All labour
   - Other Breakdown: Hidden
6. Selects filter: "All"
7. View shows all costs
```

## ✅ Testing Checklist

### Test 1: Add Material Cost
- [ ] Click + button
- [ ] Select "Add Material Cost"
- [ ] Fill all required fields
- [ ] Verify total cost auto-calculates
- [ ] Click Add
- [ ] Verify success message
- [ ] Verify utilization reloads
- [ ] Verify material appears in breakdown
- [ ] Verify Total Spent increases

### Test 2: Add Other Cost
- [ ] Click + button
- [ ] Select "Add Other Cost"
- [ ] Fill required fields
- [ ] Click Add
- [ ] Verify success message
- [ ] Verify utilization reloads
- [ ] Verify cost appears in Other breakdown
- [ ] Verify Total Spent increases

### Test 3: Filter by Material
- [ ] Select "Material" filter
- [ ] Verify only material costs shown
- [ ] Verify Total Spent = material total
- [ ] Verify Labour/Other breakdowns hidden

### Test 4: Filter by Labour
- [ ] Select "Labour" filter
- [ ] Verify only labour costs shown
- [ ] Verify Total Spent = labour total
- [ ] Verify Material/Other breakdowns hidden

### Test 5: Filter by Other
- [ ] Select "Other" filter
- [ ] Verify only other costs shown
- [ ] Verify Total Spent = other total
- [ ] Verify Material/Labour breakdowns hidden

### Test 6: Combined Filters
- [ ] Select date filter + Material filter
- [ ] Verify correct filtering
- [ ] Clear filters
- [ ] Verify all costs shown

## 📝 Files to Modify

### Backend
- ✅ `django-backend/api/views_budget_management.py` - Added add_material_cost() and add_other_cost() APIs
- ✅ `django-backend/api/views_budget_management.py` - Updated get_budget_utilization() with filter support

### Flutter
- ⏳ `otp_phone_auth/lib/services/budget_management_service.dart` - Add new methods (partially done)
- ⏳ `otp_phone_auth/lib/screens/admin_budget_management_screen.dart` - Add UI components

### Database
- ✅ `material_cost_tracking` table - Already exists
- ✅ `vendor_bills` table - Already exists

## 🎉 Status

**Backend**: ✅ Complete  
**Flutter Service**: ⏳ Partially Complete  
**Flutter UI**: ⏳ Not Started  

**Next Steps**:
1. Complete Flutter service updates
2. Add UI components to admin_budget_management_screen.dart
3. Test complete flow
4. Deploy and verify

---

**Implementation Date**: 2026-05-08  
**Feature**: Add Costs & Enhanced Filtering  
**Status**: ⏳ In Progress
