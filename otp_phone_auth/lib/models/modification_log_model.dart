class ModificationLogModel {
  final String id;
  final String entryId;
  final String siteId;
  final String siteName;
  final String modifiedBy;
  final String modifierName;
  final String modifierRole;
  final String fieldModified;
  final dynamic oldValue;
  final dynamic newValue;
  final String reason;
  final DateTime modifiedAt;

  ModificationLogModel({
    required this.id,
    required this.entryId,
    required this.siteId,
    required this.siteName,
    required this.modifiedBy,
    required this.modifierName,
    required this.modifierRole,
    required this.fieldModified,
    required this.oldValue,
    required this.newValue,
    required this.reason,
    required this.modifiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entryId': entryId,
      'siteId': siteId,
      'siteName': siteName,
      'modifiedBy': modifiedBy,
      'modifierName': modifierName,
      'modifierRole': modifierRole,
      'fieldModified': fieldModified,
      'oldValue': oldValue,
      'newValue': newValue,
      'reason': reason,
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }

  factory ModificationLogModel.fromMap(Map<String, dynamic> map) {
    return ModificationLogModel(
      id: map['id'] ?? '',
      entryId: map['entryId'] ?? '',
      siteId: map['siteId'] ?? '',
      siteName: map['siteName'] ?? '',
      modifiedBy: map['modifiedBy'] ?? '',
      modifierName: map['modifierName'] ?? '',
      modifierRole: map['modifierRole'] ?? '',
      fieldModified: map['fieldModified'] ?? '',
      oldValue: map['oldValue'],
      newValue: map['newValue'],
      reason: map['reason'] ?? '',
      modifiedAt: DateTime.parse(map['modifiedAt']),
    );
  }
}
