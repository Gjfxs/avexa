
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static final _supabase = Supabase.instance.client;

  static Future<void> createProfileIfNeeded() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      debugPrint('PROFILE: No authenticated user.');
      throw Exception('User is not authenticated.');
    }

    final username =
        user.userMetadata?['full_name']?.toString() ??
        user.userMetadata?['name']?.toString() ??
        user.email?.split('@').first ??
        'User';

    try {
      await _supabase.from('profiles').upsert(
        {
          'id': user.id,
          'username': username,
        },
        onConflict: 'id',
        ignoreDuplicates: true,
      );

      debugPrint('PROFILE: Profile ensured for ${user.id}');
    } catch (e, stackTrace) {
      debugPrint('PROFILE CREATION ERROR: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }
}
