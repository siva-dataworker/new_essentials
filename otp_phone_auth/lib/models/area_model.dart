class AreaModel {
  final String id;
  final String name;
  final int siteCount;

  AreaModel({
    required this.id,
    required this.name,
    required this.siteCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'siteCount': siteCount,
    };
  }

  factory AreaModel.fromMap(Map<String, dynamic> map) {
    return AreaModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      siteCount: map['siteCount'] ?? 0,
    );
  }
}
