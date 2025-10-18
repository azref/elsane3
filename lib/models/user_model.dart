import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType {
  client,
  craftsman,
  supplier,
}

class UserModel {
  final String uid;
  final String name; // تم إضافة هذا الحقل
  final String email;
  final String phone; // تم إضافة هذا الحقل
  final UserType userType;
  final String country; // تم إضافة هذا الحقل
  final String? dialect;
  final String? profession; // تم تغيير الاسم من professionConceptKey
  final int? experienceYears; // تم إضافة هذا الحقل
  final List<String> workCities; // تم تغييرها لتكون غير قابلة للقيم الفارغة
  final String? profilePictureUrl; // تم إضافة هذا الحقل
  final bool isOnline; // تم إضافة هذا الحقل
  final DateTime createdAt;
  final DateTime lastSeen;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    required this.country,
    this.dialect,
    this.profession,
    this.experienceYears,
    required this.workCities,
    this.profilePictureUrl,
    this.isOnline = false,
    required this.createdAt,
    required this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.toString() == 'UserType.' + (data['userType'] ?? 'client'),
        orElse: () => UserType.client,
      ),
      country: data['country'] ?? '',
      dialect: data['dialect'],
      profession: data['profession'], // تم التغيير هنا
      experienceYears: data['experienceYears'],
      workCities: List<String>.from(data['workCities'] ?? []),
      profilePictureUrl: data['profilePictureUrl'],
      isOnline: data['isOnline'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // دالة toMap متوافقة مع Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType.toString().split('.').last,
      'country': country,
      'dialect': dialect,
      'profession': profession, // تم التغيير هنا
      'experienceYears': experienceYears,
      'workCities': workCities,
      'profilePictureUrl': profilePictureUrl,
      'isOnline': isOnline,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': Timestamp.fromDate(lastSeen),
    };
  }

  // دالة fromFirestore لتسهيل التحويل من DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    UserType? userType,
    String? country,
    String? dialect,
    String? profession,
    int? experienceYears,
    List<String>? workCities,
    String? profilePictureUrl,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      country: country ?? this.country,
      dialect: dialect ?? this.dialect,
      profession: profession ?? this.profession,
      experienceYears: experienceYears ?? this.experienceYears,
      workCities: workCities ?? this.workCities,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
