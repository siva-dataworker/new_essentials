import '../models/area_model.dart';
import '../models/street_model.dart';
import '../models/site_model.dart';
import '../models/user_model.dart';

class MockDataProvider {
  // Areas
  static final List<AreaModel> areas = [
    AreaModel(id: 'area1', name: 'Kasakudy', siteCount: 8),
    AreaModel(id: 'area2', name: 'Thiruvettakudy', siteCount: 5),
    AreaModel(id: 'area3', name: 'Karaikal', siteCount: 4),
  ];

  // Streets
  static final List<StreetModel> streets = [
    // Kasakudy streets
    StreetModel(id: 'street1', areaId: 'area1', name: 'Saudha Garden', siteCount: 3),
    StreetModel(id: 'street2', areaId: 'area1', name: 'Sumaya Garden', siteCount: 3),
    StreetModel(id: 'street3', areaId: 'area1', name: 'Kasakudy Main Road', siteCount: 2),
    
    // Thiruvettakudy streets
    StreetModel(id: 'street4', areaId: 'area2', name: 'Temple Street', siteCount: 2),
    StreetModel(id: 'street5', areaId: 'area2', name: 'Beach Road', siteCount: 3),
    
    // Karaikal streets
    StreetModel(id: 'street6', areaId: 'area3', name: 'Gandhi Nagar', siteCount: 2),
    StreetModel(id: 'street7', areaId: 'area3', name: 'Nehru Street', siteCount: 2),
  ];

  // Sites
  static final List<SiteModel> sites = [
    // Saudha Garden sites
    SiteModel(
      id: 'site1',
      areaId: 'area1',
      streetId: 'street1',
      name: 'Saudha 1 12',
      customerName: 'Rajesh Kumar',
      builtUpArea: 1200,
      projectValue: 2500000,
      startDate: DateTime(2024, 1, 15),
      status: SiteStatus.active,
      createdAt: DateTime(2024, 1, 10),
    ),
    SiteModel(
      id: 'site2',
      areaId: 'area1',
      streetId: 'street1',
      name: 'Saudha 2 8',
      customerName: 'Priya Sharma',
      builtUpArea: 1500,
      projectValue: 3200000,
      startDate: DateTime(2024, 2, 1),
      status: SiteStatus.active,
      createdAt: DateTime(2024, 1, 25),
    ),
    SiteModel(
      id: 'site3',
      areaId: 'area1',
      streetId: 'street1',
      name: 'Saudha 3 15',
      customerName: 'Mohammed Ali',
      builtUpArea: 1800,
      projectValue: 4000000,
      startDate: DateTime(2024, 3, 10),
      status: SiteStatus.active,
      createdAt: DateTime(2024, 3, 1),
    ),
    
    // Sumaya Garden sites
    SiteModel(
      id: 'site4',
      areaId: 'area1',
      streetId: 'street2',
      name: 'Sumaya 1 18',
      customerName: 'Sasikumar',
      builtUpArea: 2000,
      projectValue: 4500000,
      startDate: DateTime(2024, 1, 20),
      status: SiteStatus.active,
      createdAt: DateTime(2024, 1, 15),
    ),
    SiteModel(
      id: 'site5',
      areaId: 'area1',
      streetId: 'street2',
      name: 'Sumaya 2 22',
      customerName: 'Lakshmi Devi',
      builtUpArea: 1600,
      projectValue: 3500000,
      startDate: DateTime(2024, 2, 15),
      status: SiteStatus.active,
      createdAt: DateTime(2024, 2, 10),
    ),
    SiteModel(
      id: 'site6',
      areaId: 'area1',
      streetId: 'street2',
      name: 'Sumaya 3 5',
      customerName: 'Venkatesh',
      builtUpArea: 1400,
      projectValue: 3000000,
      startDate: DateTime(2024, 3, 1),
      status: SiteStatus.active,
      createdAt: DateTime(2024, 2, 25),
    ),
    
    // Kasakudy Main Road sites
    SiteModel(
      id: 'site7',
      areaId: 'area1',
      streetId: 'street3',
      name: 'KMR 45',
      customerName: 'Anitha Reddy',
      builtUpArea: 2200,
      projectValue: 5000000,
      startDate: DateTime(2024, 1, 5),
      status: SiteStatus.active,
      createdAt: DateTime(2023, 12, 20),
    ),
    SiteModel(
      id: 'site8',
      areaId: 'area1',
      streetId: 'street3',
      name: 'KMR 67',
      customerName: 'Suresh Babu',
      builtUpArea: 1300,
      projectValue: 2800000,
      startDate: DateTime(2024, 2, 20),
      status: SiteStatus.active,
      createdAt: DateTime(2024, 2, 15),
    ),
    
    // Thiruvettakudy sites
    SiteModel(
      id: 'site9',
      areaId: 'area2',
      streetId: 'street4',
      name: 'Temple 12',
      customerName: 'Ganesh Iyer',
      builtUpArea: 1100,
      projectValue: 2400000,
      startDate: DateTime(2024, 3, 5),
      status: SiteStatus.active,
      createdAt: DateTime(2024, 3, 1),
    ),
    SiteModel(
      id: 'site10',
      areaId: 'area2',
      streetId: 'street4',
      name: 'Temple 28',
      customerName: 'Meena Kumari',
      builtUpArea: 1700,
      projectValue: 3800000,
      startDate: DateTime(2024, 1, 25),
      status: SiteStatus.active,
      createdAt: DateTime(2024, 1, 20),
    ),
  ];

  // Mock users
  static final List<UserModel> users = [
    UserModel(
      uid: 'user1',
      phoneNumber: '+918754140702',
      name: 'Ravi Supervisor',
      age: 35,
      role: UserRole.supervisor,
      assignedSites: ['site1', 'site2', 'site4'],
      createdAt: DateTime(2024, 1, 1),
      isProfileComplete: true,
    ),
    UserModel(
      uid: 'user2',
      phoneNumber: '+919876543210',
      name: 'Kumar Engineer',
      age: 30,
      role: UserRole.siteEngineer,
      assignedSites: ['site1', 'site2', 'site3', 'site4'],
      createdAt: DateTime(2024, 1, 1),
      isProfileComplete: true,
    ),
    UserModel(
      uid: 'user3',
      phoneNumber: '+919876543211',
      name: 'Priya Accountant',
      age: 28,
      role: UserRole.accountant,
      assignedSites: [],
      createdAt: DateTime(2024, 1, 1),
      isProfileComplete: true,
    ),
    UserModel(
      uid: 'user4',
      phoneNumber: '+919876543212',
      name: 'Arun Architect',
      age: 40,
      role: UserRole.architect,
      assignedSites: [],
      createdAt: DateTime(2024, 1, 1),
      isProfileComplete: true,
    ),
    UserModel(
      uid: 'user5',
      phoneNumber: '+919876543213',
      name: 'Vijay Owner',
      age: 50,
      role: UserRole.owner,
      assignedSites: [],
      createdAt: DateTime(2024, 1, 1),
      isProfileComplete: true,
    ),
  ];

  // Helper methods
  static List<StreetModel> getStreetsByArea(String areaId) {
    return streets.where((s) => s.areaId == areaId).toList();
  }

  static List<SiteModel> getSitesByStreet(String streetId) {
    return sites.where((s) => s.streetId == streetId).toList();
  }

  static List<SiteModel> getSitesByArea(String areaId) {
    return sites.where((s) => s.areaId == areaId).toList();
  }

  static SiteModel? getSiteById(String siteId) {
    try {
      return sites.firstWhere((s) => s.id == siteId);
    } catch (e) {
      return null;
    }
  }

  static AreaModel? getAreaById(String areaId) {
    try {
      return areas.firstWhere((a) => a.id == areaId);
    } catch (e) {
      return null;
    }
  }

  static StreetModel? getStreetById(String streetId) {
    try {
      return streets.firstWhere((s) => s.id == streetId);
    } catch (e) {
      return null;
    }
  }

  static UserModel? getUserById(String userId) {
    try {
      return users.firstWhere((u) => u.uid == userId);
    } catch (e) {
      return null;
    }
  }

  static List<SiteModel> getUserSites(String userId) {
    final user = getUserById(userId);
    if (user == null) return [];
    
    if (user.canViewAllSites) {
      return sites;
    }
    
    return sites.where((s) => user.assignedSites.contains(s.id)).toList();
  }
}
