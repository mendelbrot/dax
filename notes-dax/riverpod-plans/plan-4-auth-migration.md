# Plan 4: Migrate AuthProvider to Riverpod

**Objective:** Convert `AuthProvider` from Provider/ChangeNotifier to Riverpod.

**Risk Level:** Medium  
**Estimated Time:** 2-3 hours

**Prerequisite:** Plans 1-3 completed

---

## Checklist

- [ ] Create `auth_providers.dart` with Riverpod
- [ ] Update `main.dart` to remove Provider wrapper
- [ ] Update `app_router.dart` for Riverpod
- [ ] Update `sign_in_page.dart` to use Riverpod
- [ ] Update `home_page.dart` sign-out button
- [ ] Test complete auth flow
- [ ] Remove old `auth_provider.dart` (optional, can keep for reference)

---

## Step 1: Create Auth Provider with Riverpod

Create `client-flutter/lib/providers/auth_providers.dart`:

```dart
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_provider.dart';

part 'auth_providers.g.dart';

/// Auth state data class
class AppAuthState {
  final bool isAuthenticated;
  final String? userEmail;
  final bool isLoading;
  final String? errorMessage;

  const AppAuthState({
    required this.isAuthenticated,
    this.userEmail,
    this.isLoading = false,
    this.errorMessage,
  });

  AppAuthState copyWith({
    bool? isAuthenticated,
    String? userEmail,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userEmail: userEmail ?? this.userEmail,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Main auth provider
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  AppAuthState build() {
    final supabase = ref.watch(supabaseClientProvider);
    final user = supabase.auth.currentUser;

    // Listen to auth state changes
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      state = AppAuthState(
        isAuthenticated: user != null,
        userEmail: user?.email,
      );
    });

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return AppAuthState(
      isAuthenticated: user != null,
      userEmail: user?.email,
    );
  }

  Future<void> sendOTP(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.auth.signInWithOtp(email: email.trim());
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<bool> verifyOTP(String email, String token) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.email,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.auth.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    return error.toString();
  }
}

/// Convenience provider for checking auth status
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  return ref.watch(authProvider).isAuthenticated;
}
```

> [!IMPORTANT]
> Using `@Riverpod(keepAlive: true)` ensures the auth provider persists across the app lifecycle.

---

## Step 2: Update main.dart

Remove the `ChangeNotifierProvider` wrapper and let `ProviderScope` handle everything:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'services/app_router.dart';
import 'services/supabase_service.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  setPathUrlStrategy();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (supabaseUrl.isEmpty) {
    throw StateError('Missing: SUPABASE_URL');
  }
  if (supabasePublishableKey.isEmpty) {
    throw StateError('Missing: SUPABASE_PUBLISHABLE_KEY');
  }

  await SupabaseService.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'dax',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
```

---

## Step 3: Update app_router.dart

Create a Riverpod-aware router:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dax/pages/home_page.dart';
import 'package:dax/pages/sign_in_page.dart';
import 'package:dax/pages/vault_page.dart';
import 'package:dax/pages/vault_settings_page.dart';
import 'package:dax/pages/entry_page.dart';
import 'package:dax/providers/auth_providers.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isSignInRoute = state.matchedLocation == '/sign-in';

      if (!isAuthenticated && !isSignInRoute) {
        return '/sign-in';
      }
      if (isAuthenticated && isSignInRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/vault/:vaultId',
        builder: (context, state) {
          final vaultId = state.pathParameters['vaultId']!;
          return VaultPage(vaultId: vaultId);
        },
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) {
              final vaultId = state.pathParameters['vaultId']!;
              return VaultSettingsPage(vaultId: vaultId);
            },
          ),
          GoRoute(
            path: 'entry/:entryId',
            builder: (context, state) {
              final vaultId = state.pathParameters['vaultId']!;
              final entryId = state.pathParameters['entryId']!;
              return EntryPage(vaultId: vaultId, entryId: entryId);
            },
          ),
        ],
      ),
    ],
  );
}
```

---

## Step 4: Update sign_in_page.dart

Convert to `ConsumerStatefulWidget`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dax/providers/auth_providers.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  // ... existing state variables ...

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    // Use authState.isLoading, authState.errorMessage, etc.
    // Use authNotifier.sendOTP(), authNotifier.verifyOTP(), etc.
    
    // ... rest of build method, replacing:
    // context.read<AuthProvider>() -> ref.read(authProvider.notifier)
    // context.watch<AuthProvider>() -> ref.watch(authProvider)
  }
}
```

---

## Step 5: Update home_page.dart Sign-Out

Update the sign-out button in `home_page.dart`:

```dart
// Change from:
// import 'package:provider/provider.dart';
// await context.read<AuthProvider>().signOut();

// To:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dax/providers/auth_providers.dart';

// In the widget (convert to ConsumerWidget or ConsumerStatefulWidget):
IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    await ref.read(authProvider.notifier).signOut();
  },
  tooltip: 'Sign Out',
),
```

---

## Step 6: Run Code Generation

```bash
cd client-flutter
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Step 7: Test Auth Flow

1. **Fresh app start** — Should redirect to sign-in if not authenticated
2. **Send OTP** — Email should be sent, loading state shown
3. **Verify OTP** — Should authenticate and redirect to home
4. **Sign out** — Should redirect back to sign-in
5. **Deep link while signed out** — Should redirect to sign-in
6. **Session persistence** — Refresh app while signed in, should stay signed in

---

## Cleanup (Optional)

After verifying everything works:

1. Remove `provider` package from `pubspec.yaml`
2. Delete `lib/services/auth_provider.dart`
3. Remove any remaining `provider` imports

---

## Success Criteria

- [ ] Auth flow works end-to-end
- [ ] Router redirects correctly based on auth state
- [ ] No Provider package usage remaining
- [ ] Session persists across app restarts
- [ ] Error messages display correctly
