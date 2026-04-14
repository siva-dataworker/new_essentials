# Site Engineer Dashboard Implementation Plan

## Requirements Summary

### 1. Site Selection
- Dropdown to choose site
- Engineer can be assigned to multiple sites

### 2. Daily Work Updates
- **Morning Update (before 1pm)**: Upload "Work Started" photo
  - If not uploaded by 1pm → Notification to Architect & Owner
- **Evening Update**: Upload "Work Finished" photo
  - Only "Work Finished" photos sent to client
  - "Work Started" photos for internal tracking only

### 3. Client Complaints Management
- View complaints raised by Architect
- Upload rectification photos
- Photos sent to Client & Architect
- Mark complaint as resolved

### 4. Extra Works & Labour Count
- Note extra works bills
- Record labour count
- Send to Accountant via WhatsApp (group)

### 5. Project Files
- Download project files uploaded by Architect for each site

## Database Tables (Already Exist)
- ✅ `work_activity` - For work started/finished photos
- ✅ `complaints` - Client complaints
- ✅ `complaint_actions` - Rectification photos
- ✅ `notifications` - For alerts
- ✅ `daily_site_report` - Daily reports per site
- ✅ `sites` - Site information

## Implementation Steps

### Phase 1: Backend APIs (Django)
1. Site Engineer endpoints:
   - GET `/api/engineer/sites/` - Get assigned sites
   - POST `/api/engineer/work-activity/` - Upload work photos
   - GET `/api/engineer/complaints/` - Get complaints for site
   - POST `/api/engineer/complaint-action/` - Upload rectification photo
   - GET `/api/engineer/project-files/` - Get project files for site
   - POST `/api/engineer/extra-work/` - Submit extra work/labour
   - GET `/api/engineer/daily-status/` - Check if morning update done

2. Notification system:
   - Check if morning update uploaded by 1pm
   - Send notifications to Architect & Owner

### Phase 2: Flutter UI
1. Site Engineer Dashboard (Instagram-style)
   - Site selector dropdown
   - Daily checklist (Morning/Evening updates)
   - Complaints section with badge
   - Quick actions (Extra work, Labour count)
   - Project files section

2. Work Update Screen
   - Camera integration
   - Photo preview
   - Upload with notes
   - Status indicator

3. Complaints Screen
   - List of open complaints
   - Complaint details
   - Photo upload for rectification
   - Mark as resolved

4. Extra Work Screen
   - Form for extra work details
   - Labour count input
   - WhatsApp integration (share to group)

5. Project Files Screen
   - List of files per site
   - Download functionality
   - File viewer

## Features
- ✅ Provider state management (no repeated loading)
- ✅ Instagram-style design
- ✅ Photo upload with camera
- ✅ Notifications
- ✅ WhatsApp integration
- ✅ File download
- ✅ Real-time status updates

## Next Steps
1. Create backend APIs
2. Create Flutter screens
3. Integrate camera & file picker
4. Add WhatsApp sharing
5. Implement notification system
