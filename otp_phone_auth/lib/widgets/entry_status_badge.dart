// Entry Status Badge Widget
// Reusable status indicator
// Date: 2026-05-12

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/supervisor_entry_model.dart';

class EntryStatusBadge extends StatelessWidget {
  final EntryStatus status;
  final bool isLocked;

  const EntryStatusBadge({
    super.key,
    required this.status,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: config.color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 16.sp, color: config.color),
          SizedBox(width: 6.w),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    if (isLocked) {
      return _StatusConfig(
        label: 'Locked',
        icon: Icons.lock,
        color: Colors.grey.shade600,
      );
    }

    switch (status) {
      case EntryStatus.pending:
        return _StatusConfig(
          label: 'Pending',
          icon: Icons.pending_outlined,
          color: Colors.orange.shade600,
        );
      case EntryStatus.laborAdded:
        return _StatusConfig(
          label: 'Labor Added',
          icon: Icons.people,
          color: Colors.blue.shade600,
        );
      case EntryStatus.photosAdded:
        return _StatusConfig(
          label: 'Photos Added',
          icon: Icons.photo_camera,
          color: Colors.purple.shade600,
        );
      case EntryStatus.completed:
        return _StatusConfig(
          label: 'Completed',
          icon: Icons.check_circle,
          color: Colors.green.shade600,
        );
      case EntryStatus.eveningUpdated:
        return _StatusConfig(
          label: 'Evening Updated',
          icon: Icons.nightlight_round,
          color: Colors.indigo.shade600,
        );
      case EntryStatus.locked:
        return _StatusConfig(
          label: 'Locked',
          icon: Icons.lock,
          color: Colors.grey.shade600,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color color;

  _StatusConfig({required this.label, required this.icon, required this.color});
}

/// Worker Counter Widget
class WorkerCounter extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final IconData icon;
  final Color color;

  const WorkerCounter({
    super.key,
    required this.label,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 12.w),

          // Label
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),

          // Counter controls
          Row(
            children: [
              // Decrement button
              InkWell(
                onTap: count > 0 ? onDecrement : null,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: count > 0
                        ? Colors.red.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: count > 0
                          ? Colors.red.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 20.sp,
                    color: count > 0
                        ? Colors.red.shade600
                        : Colors.grey.shade400,
                  ),
                ),
              ),

              // Count display
              Container(
                width: 50.w,
                alignment: Alignment.center,
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),

              // Increment button
              InkWell(
                onTap: onIncrement,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 20.sp,
                    color: Colors.green.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Summary Card Widget
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios, size: 16.sp, color: color),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
