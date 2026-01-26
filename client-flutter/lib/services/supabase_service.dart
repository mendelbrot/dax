import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static Future<void> initialize({
    required String url,
    required String publishableKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: publishableKey);
    _client = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }
}
