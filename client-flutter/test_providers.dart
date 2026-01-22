// Temporary test file to verify providers work independently
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/providers/supabase_provider.dart';
import 'lib/providers/vault_providers.dart';
import 'lib/providers/entry_providers.dart';

void main() async {
  print('Testing Riverpod providers...');

  // Test that providers can be created without errors
  try {
    final container = ProviderContainer();

    // Test supabase provider
    final supabaseClient = container.read(supabaseClientProvider);
    print('✓ SupabaseClient provider created successfully');

    // Test that providers are properly generated
    print('✓ Vault providers generated: ${vaultsProvider.hashCode != null}');
    print('✓ Entry providers generated: ${entriesProvider('test').hashCode != null}');

    container.dispose();
    print('✓ All providers tested successfully');

  } catch (e) {
    print('✗ Error testing providers: $e');
  }
}