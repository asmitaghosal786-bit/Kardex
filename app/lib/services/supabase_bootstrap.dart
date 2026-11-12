import 'package:supabase_flutter/supabase_flutter.dart';

bool supabaseConfigured = false;

Future<void> initializeSupabase() async {
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (url.isEmpty || anonKey.isEmpty) {
    return;
  }
  await Supabase.initialize(url: url, publishableKey: anonKey);
  supabaseConfigured = true;
}
