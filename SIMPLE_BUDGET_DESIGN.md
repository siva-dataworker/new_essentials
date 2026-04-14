# Simple Budget Management Design

## Admin Flow

```
Admin Dashboard
    ↓
Budget Management
    ↓
Select Site (Dropdown)
    ↓
View Everything for That Site:
├─ Budget Allocation
├─ Labour Count
├─ Material Count
├─ Balance
├─ Bills Viewing (uploaded by accountant)
└─ Complete Accounts (Profit & Loss)
```

## Single Screen Layout

```
┌─────────────────────────────────────────────────┐
│         Budget Management                       │
├─────────────────────────────────────────────────┤
│                                                 │
│  Select Site: [Downtown Construction ▼]        │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │  BUDGET ALLOCATION                        │ │
│  │  Allocated:  ₹60,00,000                   │ │
│  │  Used:       ₹45,00,000                   │ │
│  │  Balance:    ₹15,00,000                   │ │
│  │  [████████░░] 75%                         │ │
│  │  [Update Budget]                          │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │  LABOUR COUNT                             │ │
│  │  Total Workers: 45                        │ │
│  │  Labour Cost:   ₹25,00,000                │ │
│  │  [View Details]                           │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │  MATERIAL COUNT                           │ │
│  │  Total Bills:    12                       │ │
│  │  Material Cost:  ₹20,00,000               │ │
│  │  [View Bills]                             │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │  BILLS VIEWING                            │ │
│  │  (Updated by Accountant)                  │ │
│  │  • Bill #001 - ₹5,00,000 - Cement        │ │
│  │  • Bill #002 - ₹3,00,000 - Steel         │ │
│  │  • Bill #003 - ₹2,00,000 - Sand          │ │
│  │  [View All Bills]                         │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │  COMPLETE ACCOUNTS (P&L)                  │ │
│  │  Revenue:        ₹60,00,000               │ │
│  │  Labour Cost:    ₹25,00,000               │ │
│  │  Material Cost:  ₹20,00,000               │ │
│  │  Total Cost:     ₹45,00,000               │ │
│  │  ─────────────────────────────────        │ │
│  │  Profit:         ₹15,00,000 (25%)        │ │
│  │  [View Full P&L]                          │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Features

### 1. Site Selection
- Dropdown at top
- Shows all sites
- When selected, loads all data for that site

### 2. Budget Allocation
- Shows allocated amount
- Shows used amount
- Shows balance (remaining)
- Visual progress bar
- Button to update budget

### 3. Labour Count
- Total number of workers
- Total labour cost
- Link to view detailed labour entries

### 4. Material Count
- Total number of bills
- Total material cost
- Link to view all bills

### 5. Bills Viewing
- List of recent bills uploaded by accountant
- Shows bill number, amount, material type
- Link to view all bills with details

### 6. Complete Accounts (Profit & Loss)
- Revenue (allocated budget)
- Labour cost
- Material cost
- Total cost
- Profit/Loss calculation
- Link to detailed P&L report

## Data Flow

```
Admin selects site from dropdown
    ↓
System fetches:
├─ Budget data (allocated, used, balance)
├─ Labour entries (count, total cost)
├─ Material bills (count, total cost)
├─ Recent bills list
└─ P&L calculation
    ↓
Display all in single scrollable screen
```

## API Endpoints Needed

```
GET /api/admin/sites/                          # Get all sites for dropdown
GET /api/admin/sites/<site_id>/budget/         # Get budget data
GET /api/admin/sites/<site_id>/labour-summary/ # Get labour count & cost
GET /api/admin/sites/<site_id>/material-summary/ # Get material count & cost
GET /api/admin/sites/<site_id>/bills/          # Get bills list
GET /api/admin/sites/<site_id>/profit-loss/    # Get P&L data
POST /api/admin/sites/<site_id>/budget/set/    # Update budget
```

## Implementation

### Flutter Screen Structure

```dart
class SimpleBudgetManagementScreen extends StatefulWidget {
  @override
  _SimpleBudgetManagementScreenState createState() => _SimpleBudgetManagementScreenState();
}

class _SimpleBudgetManagementScreenState extends State<SimpleBudgetManagementScreen> {
  String? selectedSiteId;
  List<Site> sites = [];
  BudgetData? budgetData;
  LabourSummary? labourSummary;
  MaterialSummary? materialSummary;
  List<Bill> recentBills = [];
  ProfitLossData? plData;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budget Management')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Site Dropdown
            _buildSiteDropdown(),
            
            if (selectedSiteId != null) ...[
              SizedBox(height: 24),
              
              // Budget Allocation Card
              _buildBudgetCard(),
              
              SizedBox(height: 16),
              
              // Labour Count Card
              _buildLabourCard(),
              
              SizedBox(height: 16),
              
              // Material Count Card
              _buildMaterialCard(),
              
              SizedBox(height: 16),
              
              // Bills Viewing Card
              _buildBillsCard(),
              
              SizedBox(height: 16),
              
              // Profit & Loss Card
              _buildProfitLossCard(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSiteDropdown() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          value: selectedSiteId,
          decoration: InputDecoration(
            labelText: 'Select Site',
            border: OutlineInputBorder(),
          ),
          items: sites.map((site) {
            return DropdownMenuItem(
              value: site.id,
              child: Text(site.name),
            );
          }).toList(),
          onChanged: (siteId) {
            setState(() {
              selectedSiteId = siteId;
            });
            _loadSiteData(siteId!);
          },
        ),
      ),
    );
  }
  
  Widget _buildBudgetCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BUDGET ALLOCATION', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Allocated:'),
                Text('₹${budgetData?.allocated ?? 0}', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Used:'),
                Text('₹${budgetData?.used ?? 0}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance:'),
                Text('₹${budgetData?.balance ?? 0}', style: TextStyle(color: Colors.green)),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: budgetData?.utilizationPercentage ?? 0,
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showUpdateBudgetDialog(),
              child: Text('Update Budget'),
            ),
          ],
        ),
      ),
    );
  }
  
  // Similar cards for Labour, Material, Bills, P&L...
}
```

## Summary

This design is:
- ✅ Simple - One screen, one dropdown
- ✅ Focused - All info for selected site
- ✅ Clear - Separate cards for each section
- ✅ Actionable - Buttons to view details or update
- ✅ Complete - Shows budget, labour, material, bills, P&L

No complex tabs or navigation - just select site and see everything!
