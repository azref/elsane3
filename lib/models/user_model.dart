import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType {
  client,
  craftsman,
  supplier,
}

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserType userType;
  final String? professionConceptKey;
  final List<String>? workCities;
  final String? dialect;
  final bool isAvailable;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.userType,
    this.professionConceptKey,
    this.workCities,
    this.dialect,
    this.isAvailable = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.toString() == 'UserType.' + (data['userType'] ?? 'client'),
        orElse: () => UserType.client,
      ),
      professionConceptKey: data['professionConceptKey'],
      workCities: data['workCities'] != null
          ? List<String>.from(data['workCities'])
          : null,
      dialect: data['dialect'],
      isAvailable: data['isAvailable'] ?? false,
    );
  }

  // تم تغيير اسم الدالة من toMap إلى toFirestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'userType': userType.toString().split('.').last,
      'professionConceptKey': professionConceptKey,
      'workCities': workCities,
      'dialect': dialect,
      'isAvailable': isAvailable,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    UserType? userType,
    String? professionConceptKey,
    List<String>? workCities,
    String? dialect,
    bool? isAvailable,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      userType: userType ?? this.userType,
      professionConceptKey: professionConceptKey ?? this.professionConceptKey,
      workCities: workCities ?? this.workCities,
      dialect: dialect ?? this.dialect,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
