import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarService {
  static final supabase = Supabase.instance.client;

  // ============================================================
  // SAVE AVATAR TO PROFILE
  // ============================================================

  static Future<String?> saveAvatar(String avatar) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        print('SAVE AVATAR: NO USER');
        return null;
      }

      print('SAVE AVATAR USER: ${user.id}');
      print('SAVE AVATAR VALUE: $avatar');

      final response = await supabase
          .from('profiles')
          .update({
            'avatar_url': avatar,
          })
          .eq('id', user.id)
          .select('avatar_url')
          .single();

      print('SAVE AVATAR RESPONSE: $response');

      return response['avatar_url']?.toString();
    } catch (e, stackTrace) {
      print('====================================');
      print('SAVE AVATAR ERROR: $e');
      print('SAVE AVATAR STACK: $stackTrace');
      print('====================================');

      return null;
    }
  }

  // ============================================================
  // UPLOAD CUSTOM PROFILE PHOTO
  // ============================================================

  static Future<String?> uploadAvatar() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return null;

      final profile = await supabase
          .from('profiles')
          .select('plan')
          .eq('id', user.id)
          .maybeSingle();

      final plan = profile?['plan']?.toString().toLowerCase();

      if (plan != 'pro') {
        return null;
      }

      final picker = ImagePicker();

      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (picked == null) return null;

      final file = File(picked.path);

      final path = '${user.id}/custom_avatar.jpg';

      try {
        await supabase.storage
            .from('avatars')
            .remove([path]);
      } catch (_) {}

      await supabase.storage
          .from('avatars')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final url = supabase.storage
          .from('avatars')
          .getPublicUrl(path);

      return url;
    } catch (e) {
      print('UPLOAD AVATAR ERROR: $e');
      return null;
    }
  }

  // ============================================================
  // LOAD AVATAR FROM PROFILE
  // ============================================================

  static Future<String?> getAvatar() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final profile = await supabase
        .from('profiles')
        .select('avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) return null;

    return profile['avatar_url']?.toString();
  }
}