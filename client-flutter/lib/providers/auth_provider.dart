import 'package:dax/helpers/error_handling_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppAuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;
  String? get userEmail => user?.email;

  const AppAuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AppAuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AppAuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // If null is passed, it remains null (or clears if we follow strict copyWith pattern, but for error usually we want to explicit set/clear).
      // Actually, standard copyWith: if null passed, it's ignored. 
      // To clear error, we need to pass null. But standard copyWith ignores null.
      // So I'll just reconstruct state in methods to be safe.
    );
  }
}

class AuthNotifier extends Notifier<AppAuthState> {
  @override
  AppAuthState build() {
    // Listen to Supabase auth changes
    final subscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      // Only update if user changed to avoid unnecessary rebuilds if just token refreshed?
      // Actually Supabase emits events.
      if (state.user != user) {
        state = AppAuthState(
          user: user,
          isLoading: false, 
          errorMessage: null, // Clear error on auth state change (success)
        );
      }
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return AppAuthState(
      user: Supabase.instance.client.auth.currentUser,
    );
  }

  Future<void> sendOTP(String email) async {
    state = AppAuthState(
      user: state.user,
      isLoading: true,
      errorMessage: null,
    );

    try {
      await Supabase.instance.client.auth.signInWithOtp(email: email.trim());
      state = AppAuthState(
        user: state.user,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = AppAuthState(
        user: state.user,
        isLoading: false,
        errorMessage: getErrorMessage(e),
      );
    }
  }

  Future<bool> verifyOTP(String email, String token) async {
    state = AppAuthState(
      user: state.user,
      isLoading: true,
      errorMessage: null,
    );

    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.email,
      );
      // State update for 'user' will happen via the listener in build()
      // But we still turn off loading here
      state = AppAuthState(
        user: state.user, // Listener might update this async, but here we just stop loading
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = AppAuthState(
        user: state.user,
        isLoading: false,
        errorMessage: getErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = AppAuthState(
      user: state.user,
      isLoading: true,
      errorMessage: null,
    );

    try {
      await Supabase.instance.client.auth.signOut();
      // State update for 'user' will happen via listener
      state = AppAuthState(
        user: state.user,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = AppAuthState(
        user: state.user,
        isLoading: false,
        errorMessage: getErrorMessage(e),
      );
    }
  }

  void clearError() {
    state = AppAuthState(
      user: state.user,
      isLoading: state.isLoading,
      errorMessage: null,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AppAuthState>(AuthNotifier.new);