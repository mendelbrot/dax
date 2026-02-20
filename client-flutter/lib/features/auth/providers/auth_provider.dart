import 'package:dax/shared/utils/get_error_message.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  static User? get currentUser => Supabase.instance.client.auth.currentUser;

  static Stream<AuthState> get authStateChanges =>
      Supabase.instance.client.auth.onAuthStateChange;

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
      await Supabase.instance.client.auth.signInWithOtp(email: email.trim());
    } catch (e) {
      _errorMessage = getErrorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> verifyOTP(String email, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    bool isOTPVerified = false;

    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.email,
      );
    } catch (e) {
      _errorMessage = getErrorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
    return isOTPVerified;
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.signOut();
      _isAuthenticated = false;
      _userEmail = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = getErrorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
