class DailyEntryModel {
  final String id;
  final String siteId;
  final String siteName;
  final String userId;
  final String userName;
  final DateTime date;
  final int? laborCount;
  final DateTime? laborCountTime;
  final bool laborCountLocked;
  final Map<String, double>? materialBalance;
  final DateTime? materialBalanceTime;
  final List<String> photoUrls;
  final DateTime? photosUploadTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyEntryModel({
    required this.id,
    required this.siteId,
    required this.siteName,
    required this.userId,
    required this.userName,
    required this.date,
    this.laborCount,
    this.laborCountTime,
    this.laborCountLocked = false,
    this.materialBalance,
    this.materialBalanceTime,
    this.photoUrls = const [],
    this.photosUploadTime,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasLaborCount => laborCount != null;
  bool get hasMaterialBalance => materialBalance != null && materialBalance!.isNotEmpty;
  bool get hasPhotos => photoUrls.isNotEmpty;
  bool get isComplete => hasLaborCount && hasMaterialBalance && hasPhotos;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'siteId': siteId,
      'siteName': siteName,
      'userId': userId,
      'userName': userName,
      'date': date.toIso8601String(),
      'laborCount': laborCount,
      'laborCountTime': laborCountTime?.toIso8601String(),
      'laborCountLocked': laborCountLocked,
      'materialBalance': materialBalance,
      'materialBalanceTime': materialBalanceTime?.toIso8601String(),
      'photoUrls': photoUrls,
      'photosUploadTime': photosUploadTime?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DailyEntryModel.fromMap(Map<String, dynamic> map) {
    return DailyEntryModel(
      id: map['id'] ?? '',
      siteId: map['siteId'] ?? '',
      siteName: map['siteName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      date: DateTime.parse(map['date']),
      laborCount: map['laborCount'],
      laborCountTime: map['laborCountTime'] != null
          ? DateTime.parse(map['laborCountTime'])
          : null,
      laborCountLocked: map['laborCountLocked'] ?? false,
      materialBalance: map['materialBalance'] != null
          ? Map<String, double>.from(map['materialBalance'])
          : null,
      materialBalanceTime: map['materialBalanceTime'] != null
          ? DateTime.parse(map['materialBalanceTime'])
          : null,
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      photosUploadTime: map['photosUploadTime'] != null
          ? DateTime.parse(map['photosUploadTime'])
          : null,
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  DailyEntryModel copyWith({
    String? id,
    String? siteId,
    String? siteName,
    String? userId,
    String? userName,
    DateTime? date,
    int? laborCount,
    DateTime? laborCountTime,
    bool? laborCountLocked,
    Map<String, double>? materialBalance,
    DateTime? materialBalanceTime,
    List<String>? photoUrls,
    DateTime? photosUploadTime,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyEntryModel(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      laborCount: laborCount ?? this.laborCount,
      laborCountTime: laborCountTime ?? this.laborCountTime,
      laborCountLocked: laborCountLocked ?? this.laborCountLocked,
      materialBalance: materialBalance ?? this.materialBalance,
      materialBalanceTime: materialBalanceTime ?? this.materialBalanceTime,
      photoUrls: photoUrls ?? this.photoUrls,
      photosUploadTime: photosUploadTime ?? this.photosUploadTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
