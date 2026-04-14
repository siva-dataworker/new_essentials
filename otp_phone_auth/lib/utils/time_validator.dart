import 'package:intl/intl.dart';

class TimeValidator {
  /// Get current time in Indian Standard Time (IST)
  static DateTime getISTTime() {
    // Get current local time (which should already be in the system's timezone)
    // If the system is set to IST, this will be IST
    // If not, we need to convert from UTC
    final now = DateTime.now();
    
    // Check if we're already in IST by comparing with UTC
    final utcNow = DateTime.now().toUtc();
    final offset = now.difference(utcNow);
    
    // If offset is already 5:30, we're in IST
    if (offset.inHours == 5 && offset.inMinutes.remainder(60) == 30) {
      return now;
    }
    
    // Otherwise, convert UTC to IST
    return utcNow.add(const Duration(hours: 5, minutes: 30));
  }

  /// Format IST time for display
  static String formatISTTime(DateTime dateTime) {
    final formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  /// Format IST date and time for display
  static String formatISTDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy hh:mm a');
    return formatter.format(dateTime);
  }

  /// Check if labour entry is within allowed time (before 12:00 PM IST)
  static bool isLabourEntryOnTime() {
    final now = getISTTime();
    final deadline = DateTime(now.year, now.month, now.day, 12, 0); // 12:00 PM
    return now.isBefore(deadline);
  }

  /// Check if material entry is within allowed time (4:00 PM - 7:00 PM IST)
  static bool isMaterialEntryOnTime() {
    final now = getISTTime();
    final startTime = DateTime(now.year, now.month, now.day, 16, 0); // 4:00 PM
    final endTime = DateTime(now.year, now.month, now.day, 19, 0); // 7:00 PM
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if morning photo upload is within allowed time (before 11:00 AM IST)
  static bool isMorningPhotoOnTime() {
    final now = getISTTime();
    final deadline = DateTime(now.year, now.month, now.day, 11, 0); // 11:00 AM
    return now.isBefore(deadline);
  }

  /// Check if evening photo upload is within allowed time (4:00 PM - 7:30 PM IST)
  static bool isEveningPhotoOnTime() {
    final now = getISTTime();
    final startTime = DateTime(now.year, now.month, now.day, 16, 0); // 4:00 PM
    final endTime = DateTime(now.year, now.month, now.day, 19, 30); // 7:30 PM
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Get late entry message for labour
  static String getLabourLateMessage() {
    final now = getISTTime();
    return 'Labour entry submitted late at ${formatISTTime(now)}. Should be submitted before 12:00 PM IST.';
  }

  /// Get late entry message for material
  static String getMaterialLateMessage() {
    final now = getISTTime();
    return 'Material entry submitted at ${formatISTTime(now)}. Should be submitted between 4:00 PM - 7:00 PM IST.';
  }

  /// Get late entry message for morning photo
  static String getMorningPhotoLateMessage() {
    final now = getISTTime();
    return 'Morning photo uploaded late at ${formatISTTime(now)}. Should be uploaded before 11:00 AM IST.';
  }

  /// Get late entry message for evening photo
  static String getEveningPhotoLateMessage() {
    final now = getISTTime();
    return 'Evening photo uploaded at ${formatISTTime(now)}. Should be uploaded between 4:00 PM - 7:30 PM IST.';
  }

  /// Get time window description for labour entry
  static String getLabourTimeWindow() {
    return 'Labour entries must be submitted before 12:00 PM IST';
  }

  /// Get time window description for material entry
  static String getMaterialTimeWindow() {
    return 'Material entries must be submitted between 4:00 PM - 7:00 PM IST';
  }

  /// Get time window description for morning photo
  static String getMorningPhotoTimeWindow() {
    return 'Morning photos must be uploaded before 11:00 AM IST';
  }

  /// Get time window description for evening photo
  static String getEveningPhotoTimeWindow() {
    return 'Evening photos must be uploaded between 4:00 PM - 7:30 PM IST';
  }
}
