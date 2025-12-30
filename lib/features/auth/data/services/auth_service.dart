import 'dart:async';
import '../../domain/models/user_model.dart';

/// AuthService - Handles mock authentication operations
class AuthService {
  // Mock Database
  final List<UserModel> _registeredUsers = [
    UserModel(
      id: 'user_001',
      fullName: 'James James',
      email: 'james@gmail.com',
      phoneNumber: '+254712345678',
      walletBalance: 1500.0,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  UserModel? _currentUser;
  static const String _dummyEmail = 'james@gmail.com';
  static const String _dummyPassword = 'password123';
  static const String _dummyOTP = '123456';

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.toLowerCase() == _dummyEmail && password == _dummyPassword) {
      _currentUser = _registeredUsers.firstWhere(
            (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
      _currentUser = _currentUser!.copyWith(lastLoginAt: DateTime.now());
      return true;
    }
    return false;
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    final emailExists = _registeredUsers.any(
          (user) => user.email.toLowerCase() == email.toLowerCase(),
    );
    if (emailExists) return false;

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      walletBalance: 0.0,
      createdAt: DateTime.now(),
    );

    _registeredUsers.add(newUser);
    return true;
  }

  Future<bool> verify2FA(String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    return otp == _dummyOTP;
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 2));
    return _registeredUsers.any((u) => u.email.toLowerCase() == email.toLowerCase());
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  Future<void> updateUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = user;
    final index = _registeredUsers.indexWhere((u) => u.id == user.id);
    if (index != -1) _registeredUsers[index] = user;
  }
}