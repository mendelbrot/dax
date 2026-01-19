import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthState();
    _listenToAuthChanges();
  }

  static User? get currentUser => SupabaseService.client.auth.currentUser;

  static Stream<AuthState> get authStateChanges => SupabaseService.client.auth.onAuthStateChange;

  void _checkAuthState() {
    _isAuthenticated = currentUser != null;
    _userEmail = currentUser?.email;
    notifyListeners();
  }

  void _listenToAuthChanges() {
    authStateChanges.listen((data) {
      final user = data.session?.user;
      _isAuthenticated = user != null;
      _userEmail = user?.email;
      _errorMessage = null;
      notifyListeners();
    });
  }

  Future<void> sendOTP(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await SupabaseService.client.auth.signInWithOtp(email: email.trim());
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(String email, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await SupabaseService.client.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.email,
      );
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService.client.auth.signOut();
      _isAuthenticated = false;
      _userEmail = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    return error.toString();
  }
}
