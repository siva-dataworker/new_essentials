// Simplified Supervisor Dashboard V2
// Core functionality with clean UI
// Date: 2026-05-12

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/supervisor_entry_model.dart';
import '../providers/supervisor_entry_provider.dart';
import '../widgets/entry_status_badge.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class SupervisorDashboardV2Simple extends StatefulWidget {
  final Map<String, dynamic> site;

  const SupervisorDashboardV2Simple({super.key, required this.site});

  @override
  State<SupervisorDashboardV2Simple> createState() =>
      _SupervisorDashboardV2SimpleState();
}

class _SupervisorDashboardV2SimpleState
    extends State<SupervisorDashboardV2Simple> {
  final _authService = AuthService();
  Map<String, dynamic>? _currentUser;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeEntry();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    setState(() => _currentUser = user);
  }

  Future<void> _initializeEntry() async {
    final provider = context.read<SupervisorEntryProvider>();
    await provider.initializeEntry(
      siteId: widget.site['id'],
      siteName: widget.site['name'] ?? 'Unknown Site',
      siteLocation: widget.site['location'] ?? 'Unknown Location',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupervisorEntryProvider>(
      builder: (context, provider, child) {
        return WillPopScope(
          onWillPop: () async {
            if (!provider.canExit) {
              _showExitWarning();
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: _buildAppBar(),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(provider),
            floatingActionButton: _buildFAB(provider),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            bottomNavigationBar: _buildBottomNav(),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.deepNavy,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.site['name'] ?? 'Site',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            widget.site['location'] ?? '',
            style: TextStyle(fontSize: 12.sp, color: Colors.white70),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _initializeEntry,
          icon: const Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildBody(SupervisorEntryProvider provider) {
    final entry = provider.currentEntry;

    if (entry == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'Failed to load entry',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _initializeEntry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _initializeEntry,
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          // Site Info Card
          _buildSiteInfoCard(entry),
          SizedBox(height: 16.h),

          // Status Badge
          Center(
            child: EntryStatusBadge(
              status: entry.status,
              isLocked: entry.isLockedByOther,
            ),
          ),
          SizedBox(height: 20.h),

          // Today's Summary
          if (!entry.isLockedByOther) ...[
            _buildSummarySection(entry),
            SizedBox(height: 20.h),
          ],

          // Locked Message
          if (entry.isLockedByOther) _buildLockedMessage(entry),

          // Evening Update Section
          if (entry.canAddEvening) ...[
            _buildEveningSection(entry),
            SizedBox(height: 20.h),
          ],

          // Instructions
          if (entry.status == EntryStatus.pending && !entry.isLockedByOther)
            _buildInstructions(),

          SizedBox(height: 100.h), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSiteInfoCard(DailyEntry entry) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepNavy, AppColors.deepNavy.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.white70, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _currentUser?['name'] ?? 'Supervisor',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                DateFormat('EEEE, MMM dd, yyyy').format(entry.entryDate),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(DailyEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Summary",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Workers',
                value: entry.labourEntry?.totalWorkers.toString() ?? '0',
                icon: Icons.people,
                color: Colors.blue.shade600,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SummaryCard(
                title: 'Photos',
                value: entry.morningPhotos.length.toString(),
                icon: Icons.photo_camera,
                color: Colors.purple.shade600,
              ),
            ),
          ],
        ),
        if (entry.entryTime != null) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entry Completed',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Text(
                        'at ${DateFormat('hh:mm a').format(entry.entryTime!)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLockedMessage(DailyEntry entry) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.orange.shade200, width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.lock, size: 48.sp, color: Colors.orange.shade600),
          SizedBox(height: 16.h),
          Text(
            'Entry Locked',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Already one supervisor entered today labor entry for this site.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.orange.shade700),
          ),
          if (entry.lockedBySupervisor != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person,
                    size: 16.sp,
                    color: Colors.orange.shade600,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Entered by: ${entry.lockedBySupervisor}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEveningSection(DailyEntry entry) {
    return InkWell(
      onTap: _showEveningUpdate,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.indigo.shade400],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.nightlight_round,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evening Update',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Tap to add evening details',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600),
              SizedBox(width: 8.w),
              Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInstructionItem('1. Tap + button below'),
          _buildInstructionItem('2. Add Labour Entry (Required ⭐)'),
          _buildInstructionItem('3. Add Photos (Required ⭐)'),
          _buildInstructionItem('4. Complete both to unlock exit'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16.sp,
            color: Colors.blue.shade600,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(SupervisorEntryProvider provider) {
    final entry = provider.currentEntry;
    if (entry == null || entry.isLockedByOther) return const SizedBox.shrink();

    // If morning is complete, show evening update button
    if (entry.isMorningCompleted && !entry.isEveningCompleted) {
      return FloatingActionButton.extended(
        onPressed: _showEveningUpdate,
        backgroundColor: Colors.indigo.shade600,
        icon: const Icon(Icons.nightlight_round),
        label: const Text('Evening Update'),
      );
    }

    // If fully complete, show check icon
    if (entry.isFullyCompleted) {
      return FloatingActionButton(
        onPressed: null,
        backgroundColor: Colors.green.shade600,
        child: const Icon(Icons.check_circle),
      );
    }

    // Default: show + button
    return FloatingActionButton(
      onPressed: () => _showActionSheet(provider),
      backgroundColor: AppColors.safetyOrange,
      child: const Icon(Icons.add, size: 32),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) => setState(() => _selectedNavIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.deepNavy,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  void _showActionSheet(SupervisorEntryProvider provider) {
    final entry = provider.currentEntry!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Text(
                  'Choose Action',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildActionTile(
                icon: Icons.people,
                title: 'Labour Entry',
                subtitle: 'Required ⭐',
                color: Colors.blue.shade600,
                enabled: !entry.isLabourCompleted,
                onTap: () {
                  Navigator.pop(context);
                  _showLabourEntry(provider);
                },
              ),
              _buildActionTile(
                icon: Icons.photo_camera,
                title: 'Add Photos',
                subtitle: 'Required ⭐',
                color: Colors.purple.shade600,
                enabled: !entry.isPhotosCompleted,
                onTap: () {
                  Navigator.pop(context);
                  _showPhotoUpload(provider);
                },
              ),
              _buildActionTile(
                icon: Icons.inventory,
                title: 'Material Entry',
                subtitle: 'Optional',
                color: Colors.orange.shade600,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Material entry coming soon')),
                  );
                },
              ),
              _buildActionTile(
                icon: Icons.note_add,
                title: 'Notes / Remarks',
                subtitle: 'Optional',
                color: Colors.teal.shade600,
                onTap: () {
                  Navigator.pop(context);
                  _showNotesDialog(provider);
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ListTile(
      enabled: enabled,
      leading: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: enabled ? color : Colors.grey),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: enabled ? Colors.black87 : Colors.grey,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: enabled
          ? Icon(Icons.arrow_forward_ios, size: 16.sp)
          : Icon(Icons.check_circle, color: Colors.green.shade600),
      onTap: enabled ? onTap : null,
    );
  }

  void _showLabourEntry(SupervisorEntryProvider provider) {
    provider.startSession();
    // TODO: Show labour entry sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Labour entry sheet - Copy code from markdown file'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPhotoUpload(SupervisorEntryProvider provider) {
    // TODO: Show photo upload sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo upload sheet - Copy code from markdown file'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showEveningUpdate() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Evening update coming soon')));
  }

  void _showNotesDialog(SupervisorEntryProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Notes'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter your notes here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.addNotes(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Notes saved')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showExitWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600),
            SizedBox(width: 12.w),
            const Text('Cannot Exit'),
          ],
        ),
        content: const Text(
          'Complete Labor Entry and Photos before leaving.\n\nBoth are mandatory!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Entry'),
          ),
        ],
      ),
    );
  }
}
