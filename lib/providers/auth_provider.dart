import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  UserModel? _user;
  String? _error;
  
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get user => _user;
  String? get error => _error;
  
  AuthProvider() {
    _checkAuthState();
  }
  
  void _checkAuthState() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      final userData = await _authService.getUserData(currentUser.uid);
      _user = userData;
      _isAuthenticated = true;
      notifyListeners();
    }
  }
  
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(email, password);
      if (userCredential != null) {
        final userData = await _authService.getUserData(userCredential.user!.uid);
        _user = userData;
        _isAuthenticated = true;
        _isLoading = false;
      } else {
        _error = 'فشل في تسجيل الدخول';
        _isLoading = false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
  
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserType userType,
    required String country,
    required String dialect,
    required List<String> workCities,
    String? profession,
    int? experienceYears,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userCredential = await _authService.registerWithEmailAndPassword(
        email,
        password,
        name,
        phone,
        userType,
        country,
        dialect,
        workCities,
        profession,
        experienceYears,
      );
      
      if (userCredential != null) {
        final userData = await _authService.getUserData(userCredential.user!.uid);
        _user = userData;
        _isAuthenticated = true;
        _isLoading = false;
      } else {
        _error = 'فشل في إنشاء الحساب';
        _isLoading = false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
  
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

