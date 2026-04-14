class StreetModel {
  final String id;
  final String areaId;
  final String name;
  final int siteCount;

  StreetModel({
    required this.id,
    required this.areaId,
    required this.name,
    required this.siteCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'areaId': areaId,
      'name': name,
      'siteCount': siteCount,
    };
  }

  factory StreetModel.fromMap(Map<String, dynamic> map) {
    return StreetModel(
      id: map['id'] ?? '',
      areaId: map['areaId'] ?? '',
      name: map['name'] ?? '',
      siteCount: map['siteCount'] ?? 0,
    );
  }
}
