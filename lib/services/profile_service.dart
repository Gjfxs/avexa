
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static final _supabase = Supabase.instance.client;

  static Future<void> createProfileIfNeeded() async {
    print("CREATE PROFILE START");

    final user = _supabase.auth.currentUser;

    if (user == null) {
      print("USER IS NULL");
      return;
    }

    print("USER ID: ${user.id}");

    final existing = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (existing != null) return;

    await _supabase.from('profiles').insert({
      'id': user.id,
      'username':
          user.userMetadata?['full_name'] ??
          user.email?.split('@').first ??
          'User',
      'avatar_url': user.userMetadata?['avatar_url'],
    });
  }
}
