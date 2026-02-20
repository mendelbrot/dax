import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:dax/features/auth/presentation/pages/sign_in_page/sign_in_page.dart';
import 'package:dax/features/notebook/presentation/pages/home_page.dart';
import 'package:dax/features/notebook/presentation/pages/vault_page.dart';
import 'package:dax/features/notebook/presentation/pages/entry_page.dart';
import 'package:dax/features/notebook/presentation/pages/vault_settings_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A [Listenable] that notifies when the provided [Stream] emits a value.
/// Used to make GoRouter reactive to external state changes like Supabase auth.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  routes: [
    GoRoute(path: '/signin', builder: (context, state) => const SignInPage()),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        // Nested route for Vault
        GoRoute(
          path: 'vault/:vaultId',
          builder: (context, state) {
            final vaultId = int.parse(state.pathParameters['vaultId']!);
            return VaultPage(vaultId: vaultId);
          },
          routes: [
            // Nested route for Entry
            GoRoute(
              path: 'entry/:entryId',
              builder: (context, state) {
                final vaultId = int.parse(state.pathParameters['vaultId']!);
                final entryId = int.parse(state.pathParameters['entryId']!);
                return EntryPage(vaultId: vaultId, entryId: entryId);
              },
            ),
            // Nested route for Settings
            GoRoute(
              path: 'settings',
              builder: (context, state) {
                final vaultId = int.parse(state.pathParameters['vaultId']!);
                return VaultSettingsPage(vaultId: vaultId);
              },
            ),
          ],
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final bool isGoingToLogin = state.uri.toString() == '/signin';
    final bool isAuthenticated =
        Supabase.instance.client.auth.currentUser != null;

    if (!isAuthenticated && !isGoingToLogin) {
      return '/signin'; // Redirect to sign in if not logged in
    }

    if (isAuthenticated && isGoingToLogin) {
      return '/'; // Redirect to home if already logged in but trying to sign in
    }

    return null; // No redirection needed
  },
);
