enum UserRole {
  supervisor,
  siteEngineer,
  accountant,
  architect,
  chiefAccountant,
  owner,
  client,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.siteEngineer:
        return 'Site Engineer';
      case UserRole.accountant:
        return 'Accountant';
      case UserRole.architect:
        return 'Architect';
      case UserRole.chiefAccountant:
        return 'Chief Accountant';
      case UserRole.owner:
        return 'Owner';
      case UserRole.client:
        return 'Client';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.supervisor,
    );
  }
}

class UserModel {
  final String uid;
  final String phoneNumber;
  final String? name;
  final int? age;
  final String? email;
  final String? address;
  final UserRole role;
  final List<String> assignedSites;
  final DateTime createdAt;
  final bool isProfileComplete;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.name,
    this.age,
    this.email,
    this.address,
    this.role = UserRole.supervisor,
    this.assignedSites = const [],
    required this.createdAt,
    this.isProfileComplete = false,
    this.isActive = true,
  });

  // Permissions
  bool get canModifyLaborCount =>
      role == UserRole.accountant ||
      role == UserRole.chiefAccountant;

  bool get canViewAllSites =>
      role == UserRole.accountant ||
      role == UserRole.chiefAccountant ||
      role == UserRole.owner;

  bool get receivesNotifications =>
      role == UserRole.accountant ||
      role == UserRole.chiefAccountant ||
      role == UserRole.owner;

  bool get canEnterData =>
      role == UserRole.supervisor ||
      role == UserRole.siteEngineer ||
      role == UserRole.accountant ||
      role == UserRole.chiefAccountant;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'name': name,
      'age': age,
      'email': email,
      'address': address,
      'role': role.value,
      'assignedSites': assignedSites,
      'createdAt': createdAt.toIso8601String(),
      'isProfileComplete': isProfileComplete,
      'isActive': isActive,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'],
      age: map['age'],
      email: map['email'],
      address: map['address'],
      role: UserRoleExtension.fromString(map['role'] ?? 'supervisor'),
      assignedSites: List<String>.from(map['assignedSites'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      isProfileComplete: map['isProfileComplete'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? name,
    int? age,
    String? email,
    String? address,
    UserRole? role,
    List<String>? assignedSites,
    DateTime? createdAt,
    bool? isProfileComplete,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      address: address ?? this.address,
      role: role ?? this.role,
      assignedSites: assignedSites ?? this.assignedSites,
      createdAt: createdAt ?? this.createdAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isActive: isActive ?? this.isActive,
    );
  }
}
