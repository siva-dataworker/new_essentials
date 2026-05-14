// Supervisor Entry Model Classes
// Date: 2026-05-12

import 'package:flutter/foundation.dart';

/// Entry Status Enum
enum EntryStatus {
  pending,
  laborAdded,
  photosAdded,
  completed,
  eveningUpdated,
  locked,
}

/// Labour Entry Model
class LabourEntry {
  int masonCount;
  int helperCount;
  int carpenterCount;
  int electricianCount;
  int painterCount;
  int otherCount;

  LabourEntry({
    this.masonCount = 0,
    this.helperCount = 0,
    this.carpenterCount = 0,
    this.electricianCount = 0,
    this.painterCount = 0,
    this.otherCount = 0,
  });

  int get totalWorkers =>
      masonCount +
      helperCount +
      carpenterCount +
      electricianCount +
      painterCount +
      otherCount;

  bool get hasAnyWorkers => totalWorkers > 0;

  Map<String, dynamic> toJson() => {
    'mason': masonCount,
    'helper': helperCount,
    'carpenter': carpenterCount,
    'electrician': electricianCount,
    'painter': painterCount,
    'other': otherCount,
    'total': totalWorkers,
  };

  factory LabourEntry.fromJson(Map<String, dynamic> json) => LabourEntry(
    masonCount: json['mason'] ?? 0,
    helperCount: json['helper'] ?? 0,
    carpenterCount: json['carpenter'] ?? 0,
    electricianCount: json['electrician'] ?? 0,
    painterCount: json['painter'] ?? 0,
    otherCount: json['other'] ?? 0,
  );

  LabourEntry copyWith({
    int? masonCount,
    int? helperCount,
    int? carpenterCount,
    int? electricianCount,
    int? painterCount,
    int? otherCount,
  }) => LabourEntry(
    masonCount: masonCount ?? this.masonCount,
    helperCount: helperCount ?? this.helperCount,
    carpenterCount: carpenterCount ?? this.carpenterCount,
    electricianCount: electricianCount ?? this.electricianCount,
    painterCount: painterCount ?? this.painterCount,
    otherCount: otherCount ?? this.otherCount,
  );
}

/// Evening Update Model
class EveningUpdate {
  double totalWageAmount;
  double otAmount;
  double extraExpense;
  List<String> photoUrls;

  EveningUpdate({
    this.totalWageAmount = 0.0,
    this.otAmount = 0.0,
    this.extraExpense = 0.0,
    this.photoUrls = const [],
  });

  double get totalAmount => totalWageAmount + otAmount + extraExpense;

  bool get isComplete => totalWageAmount > 0 && photoUrls.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'total_wage': totalWageAmount,
    'ot_amount': otAmount,
    'extra_expense': extraExpense,
    'photos': photoUrls,
    'total': totalAmount,
  };

  factory EveningUpdate.fromJson(Map<String, dynamic> json) => EveningUpdate(
    totalWageAmount: (json['total_wage'] ?? 0).toDouble(),
    otAmount: (json['ot_amount'] ?? 0).toDouble(),
    extraExpense: (json['extra_expense'] ?? 0).toDouble(),
    photoUrls: List<String>.from(json['photos'] ?? []),
  );
}

/// Daily Entry Model
class DailyEntry {
  final String siteId;
  final String siteName;
  final String siteLocation;
  final DateTime entryDate;

  LabourEntry? labourEntry;
  List<String> morningPhotos;
  String? notes;
  EveningUpdate? eveningUpdate;

  EntryStatus status;
  bool isLockedByOther;
  String? lockedBySupervisor;
  DateTime? entryTime;
  DateTime? eveningUpdateTime;

  DailyEntry({
    required this.siteId,
    required this.siteName,
    required this.siteLocation,
    required this.entryDate,
    this.labourEntry,
    this.morningPhotos = const [],
    this.notes,
    this.eveningUpdate,
    this.status = EntryStatus.pending,
    this.isLockedByOther = false,
    this.lockedBySupervisor,
    this.entryTime,
    this.eveningUpdateTime,
  });

  bool get isLabourCompleted =>
      labourEntry != null && labourEntry!.hasAnyWorkers;
  bool get isPhotosCompleted => morningPhotos.isNotEmpty;
  bool get isMorningCompleted => isLabourCompleted && isPhotosCompleted;
  bool get isEveningCompleted =>
      eveningUpdate != null && eveningUpdate!.isComplete;
  bool get isFullyCompleted => isMorningCompleted && isEveningCompleted;

  bool get canExit => isMorningCompleted;
  bool get canAddEvening => isMorningCompleted && !isEveningCompleted;

  String get statusText {
    if (isLockedByOther) return 'Locked';
    if (isFullyCompleted) return 'Completed';
    if (isEveningCompleted) return 'Evening Updated';
    if (isMorningCompleted) return 'Morning Completed';
    if (isPhotosCompleted) return 'Photos Added';
    if (isLabourCompleted) return 'Labor Added';
    return 'Pending';
  }

  Map<String, dynamic> toJson() => {
    'site_id': siteId,
    'site_name': siteName,
    'site_location': siteLocation,
    'entry_date': entryDate.toIso8601String(),
    'labour_entry': labourEntry?.toJson(),
    'morning_photos': morningPhotos,
    'notes': notes,
    'evening_update': eveningUpdate?.toJson(),
    'status': status.toString(),
    'is_locked': isLockedByOther,
    'locked_by': lockedBySupervisor,
    'entry_time': entryTime?.toIso8601String(),
    'evening_time': eveningUpdateTime?.toIso8601String(),
  };

  DailyEntry copyWith({
    LabourEntry? labourEntry,
    List<String>? morningPhotos,
    String? notes,
    EveningUpdate? eveningUpdate,
    EntryStatus? status,
    bool? isLockedByOther,
    String? lockedBySupervisor,
    DateTime? entryTime,
    DateTime? eveningUpdateTime,
  }) => DailyEntry(
    siteId: siteId,
    siteName: siteName,
    siteLocation: siteLocation,
    entryDate: entryDate,
    labourEntry: labourEntry ?? this.labourEntry,
    morningPhotos: morningPhotos ?? this.morningPhotos,
    notes: notes ?? this.notes,
    eveningUpdate: eveningUpdate ?? this.eveningUpdate,
    status: status ?? this.status,
    isLockedByOther: isLockedByOther ?? this.isLockedByOther,
    lockedBySupervisor: lockedBySupervisor ?? this.lockedBySupervisor,
    entryTime: entryTime ?? this.entryTime,
    eveningUpdateTime: eveningUpdateTime ?? this.eveningUpdateTime,
  );
}
