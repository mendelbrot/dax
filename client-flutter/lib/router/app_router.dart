import 'package:go_router/go_router.dart';
import '../pages/sign_in_page.dart';
import '../pages/home_page.dart';
import '../pages/vault_page.dart';
import '../pages/entry_page.dart';
import '../pages/vault_settings_page.dart';
import '../providers/auth_provider.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
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
              final vaultId = state.pathParameters['vaultId']!;
              return VaultPage(vaultId: vaultId);
            },
            routes: [
              // Nested route for Entry
              GoRoute(
                path: 'entry/:entryId',
                builder: (context, state) {
                  final vaultId = state.pathParameters['vaultId']!;
                  final entryId = state.pathParameters['entryId']!;
                  return EntryPage(vaultId: vaultId, entryId: entryId);
                },
              ),
              // Nested route for Settings
              GoRoute(
                path: 'settings',
                builder: (context, state) {
                  final vaultId = state.pathParameters['vaultId']!;
                  return VaultSettingsPage(vaultId: vaultId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final bool isLoggedIn = authProvider.isAuthenticated;
      final bool isGoingToLogin = state.uri.toString() == '/signin';

      if (!isLoggedIn && !isGoingToLogin) {
        return '/signin'; // Redirect to sign in if not logged in
      }

      if (isLoggedIn && isGoingToLogin) {
        return '/'; // Redirect to home if already logged in but trying to sign in
      }

      return null; // No redirection needed
    },
  );
}
