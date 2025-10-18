import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // يمكنك التعامل مع الأخطاء هنا (مثل كلمة مرور خاطئة، مستخدم غير موجود)
      print('Error signing in: ${e.message}');
      return null;
    }
  }

  // تسجيل مستخدم جديد بالبريد الإلكتروني وكلمة المرور
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String phone,
    UserType userType,
    String country,
    String dialect,
    List<String> workCities,
    String? profession,
    int? experienceYears,
  ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // حفظ بيانات المستخدم في Firestore
        UserModel newUser = UserModel(
          id: userCredential.user!.uid,
          name: name,
          phone: phone,
          email: email,
          userType: userType,
          country: country,
          dialect: dialect,
          workCities: workCities,
          profession: profession,
          experienceYears: experienceYears,
          createdAt: DateTime.now(),
          lastSeen: DateTime.now(),
        );
        await _firestore.collection('users').doc(newUser.id).set(newUser.toFirestore());
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error registering user: ${e.message}');
      return null;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // الحصول على المستخدم الحالي
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // الحصول على بيانات المستخدم من Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // تحديث بيانات المستخدم في Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user data: $e');
    }
  }
}


