import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_model.dart';
import '../../data/services/auth_service.dart';

/// AUTH PROVIDERS - Manages authentication state across the app
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthStateNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AsyncValue.loading()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final user = _authService.currentUser;
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final success = await _authService.login(email, password);
      if (success) {
        state = AsyncValue.data(_authService.currentUser);
        return true;
      }
      state = const AsyncValue.data(null);
      return false;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> verify2FA(String otp, String email, String password) async {
    try {
      final isValid = await _authService.verify2FA(otp);
      if (isValid) return await login(email, password);
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      return await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _authService.updateUser(user);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateWalletBalance(double newBalance) async {
    final currentState = state;
    if (currentState is AsyncData<UserModel?>) {
      final currentUser = currentState.value;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(walletBalance: newBalance);
        await updateUser(updatedUser);
      }
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthStateNotifier(ref.read(authServiceProvider));
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});

final walletBalanceProvider = Provider<double>((ref) {
  return ref.watch(currentUserProvider)?.walletBalance ?? 0.0;
});