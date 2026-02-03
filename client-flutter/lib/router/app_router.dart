import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dax/pages/sign_in_page.dart';
import 'package:dax/pages/home_page.dart';
import 'package:dax/pages/vault_page.dart';
import 'package:dax/pages/entry_page.dart';
import 'package:dax/pages/vault_settings_page.dart';
import 'package:dax/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch only the authentication status to trigger rebuilds/redirects.
  // By using .select, we prevent the router from rebuilding when transient 
  // state like 'isLoading' or 'errorMessage' changes, which would otherwise
  // reset the navigation stack and dispose of current pages.
  final isAuthenticated = ref.watch(authProvider.select((s) => s.isAuthenticated));
  
  return GoRouter(
    initialLocation: '/',
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

      if (!isAuthenticated && !isGoingToLogin) {
        return '/signin'; // Redirect to sign in if not logged in
      }

      if (isAuthenticated && isGoingToLogin) {
        return '/'; // Redirect to home if already logged in but trying to sign in
      }

      return null; // No redirection needed
    },
  );
});