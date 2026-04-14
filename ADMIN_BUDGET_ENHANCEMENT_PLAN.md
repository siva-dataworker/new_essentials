# Admin Budget Enhancement Implementation Plan

## Overview
Comprehensive budget management system with allocation tracking, material cost management, labour rate calculations, and Excel export functionality.

## Features to Implement

### 1. Budget Allocation Dashboard Integration ✅ (Partially Done)
- [x] Budget allocation API exists
- [x] Budget display in Budget tab
- [ ] Show allocated budget in Dashboard tab
- [ ] Real-time budget updates

### 2. Material Cost Management
- [ ] Admin can view bills uploaded by accountant
- [ ] Admin can update material costs from bills
- [ ] Material cost tracking table
- [ ] Link bills to budget utilization

### 3. Labour Rate & Cost Calculation
- [x] Labour rate setting API exists
- [x] Labour rate display in Budget tab
- [ ] Auto-calculate labour costs (count × daily_rate)
- [ ] Show labour investment in utilization
- [ ] Formula: total_labour_cost = Σ(labour_count × daily_rate)

### 4. Material Management Sub-tab
- [ ] Add "Manage" sub-tab under Material tab
- [ ] Show site engineer's material balance updates
- [ ] Display material usage history
- [ ] Material cost per entry

### 5. Budget Utilization Enhancement
- [ ] Material investment breakdown
- [ ] Labour investment breakdown
- [ ] Real-time utilization percentage
- [ ] Budget status indicators (ACTIVE, EXCEEDED, COMPLETED)

### 6. Excel Export Functionality
- [ ] Backend: Generate Excel reports
- [ ] Export labour entries
- [ ] Export material entries
- [ ] Export budget utilization
- [ ] Export bills and agreements
- [ ] Role-based export permissions

## Database Schema Requirements

### Existing Tables
- `site_budget_allocation` - Budget allocation
- `labour_salary_rates` - Labour daily rates
- `labour_cost_calculation` - Auto-calculated labour costs (via trigger)
- `material_cost_tracking` - Material cost tracking
- `budget_utilization_summary` - View for utilization

### New Tables Needed
- `material_cost_updates` - Admin updates to material costs
- `export_logs` - Track export requests

## Implementation Priority

### Phase 1: Core Budget Features (HIGH PRIORITY)
1. Show allocated budget in Dashboard tab
2. Material cost management UI
3. Labour cost auto-calculation verification
4. Utilization tab enhancements

### Phase 2: Material Management (MEDIUM PRIORITY)
1. Material "Manage" sub-tab
2. Site engineer material updates visibility
3. Material cost per entry display

### Phase 3: Excel Export (MEDIUM PRIORITY)
1. Backend Excel generation (using openpyxl)
2. Export APIs for each data type
3. Flutter download functionality
4. Export history tracking

## Technical Stack

### Backend
- Python Django REST Framework
- openpyxl for Excel generation
- PostgreSQL database

### Frontend
- Flutter
- excel package for file handling
- path_provider for file storage

## API Endpoints Needed

### Material Cost Management
- `POST /api/budget/material-cost/` - Update material cost
- `GET /api/budget/material-costs/{site_id}/` - Get material costs

### Excel Export
- `GET /api/export/labour-entries/{site_id}/` - Export labour data
- `GET /api/export/material-entries/{site_id}/` - Export material data
- `GET /api/export/budget-utilization/{site_id}/` - Export budget data
- `GET /api/export/bills/{site_id}/` - Export bills data

## Files to Modify

### Backend
- `django-backend/api/views_budget_management.py` - Add material cost APIs
- `django-backend/api/views_export.py` - NEW: Excel export APIs
- `django-backend/api/urls.py` - Add new routes
- `django-backend/requirements.txt` - Add openpyxl

### Frontend
- `otp_phone_auth/lib/screens/admin_site_full_view.dart` - Add Material Manage sub-tab
- `otp_phone_auth/lib/screens/admin_budget_management_screen.dart` - Enhance utilization
- `otp_phone_auth/lib/services/export_service.dart` - NEW: Export service
- `otp_phone_auth/pubspec.yaml` - Add excel, path_provider packages

## Next Steps
1. Implement Dashboard budget display
2. Create material cost management APIs
3. Add Material Manage sub-tab
4. Implement Excel export backend
5. Add export buttons to UI
6. Test end-to-end workflow
