enum SiteStatus {
  planning,
  active,
  onHold,
  completed,
}

class SiteModel {
  final String id;
  final String areaId;
  final String streetId;
  final String name;
  final String customerName;
  final double builtUpArea;
  final double projectValue;
  final DateTime startDate;
  final SiteStatus status;
  final DateTime createdAt;

  SiteModel({
    required this.id,
    required this.areaId,
    required this.streetId,
    required this.name,
    required this.customerName,
    required this.builtUpArea,
    required this.projectValue,
    required this.startDate,
    this.status = SiteStatus.active,
    required this.createdAt,
  });

  String get displayName => '$name $customerName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'areaId': areaId,
      'streetId': streetId,
      'name': name,
      'customerName': customerName,
      'builtUpArea': builtUpArea,
      'projectValue': projectValue,
      'startDate': startDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SiteModel.fromMap(Map<String, dynamic> map) {
    return SiteModel(
      id: map['id'] ?? '',
      areaId: map['areaId'] ?? '',
      streetId: map['streetId'] ?? '',
      name: map['name'] ?? '',
      customerName: map['customerName'] ?? '',
      builtUpArea: (map['builtUpArea'] ?? 0).toDouble(),
      projectValue: (map['projectValue'] ?? 0).toDouble(),
      startDate: DateTime.parse(map['startDate']),
      status: SiteStatus.values.firstWhere(
        (s) => s.toString().split('.').last == map['status'],
        orElse: () => SiteStatus.active,
      ),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
