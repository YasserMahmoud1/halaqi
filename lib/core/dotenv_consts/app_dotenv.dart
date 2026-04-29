/// App secrets injected at build time via --dart-define.
/// These are compiled into the binary and are NOT stored as plaintext files.
/// Build command:
///   flutter build appbundle \
///     --dart-define=SUPABASE_URL=https://... \
///     --dart-define=SUPABASE_ANON_KEY=sb_publishable_...
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static bool get hasValidSupabaseConfig {
    return supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
  }

  static List<String> get missingConfigKeys {
    final missing = <String>[];
    if (supabaseUrl.trim().isEmpty) missing.add('SUPABASE_URL');
    if (supabaseAnonKey.trim().isEmpty) missing.add('SUPABASE_ANON_KEY');
    return missing;
  }
}
