
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile_service.dart';

class AvatarService {
  static final supabase = Supabase.instance.client;

  // SAVE SELECTED AVATAR
  static Future<String?> saveAvatar(String avatar) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      await ProfileService.createProfileIfNeeded();

      final response = await supabase
          .from('profiles')
          .update({'avatar_url': avatar})
          .eq('id', user.id)
          .select('avatar_url')
          .maybeSingle();

      if (response == null) {
        throw Exception('Profile was not found after creation.');
      }

      final savedAvatar = response['avatar_url']?.toString();

      if (savedAvatar == null || savedAvatar.isEmpty) {
        throw Exception('Avatar URL was not saved.');
      }

      debugPrint('AVATAR SAVED: $savedAvatar');

      return savedAvatar;
    } catch (e, stackTrace) {
      debugPrint('SAVE AVATAR ERROR: $e');
      debugPrint('$stackTrace');
      return null;
    }
  }

  // UPLOAD CUSTOM PRO PHOTO
  static Future<String?> uploadAvatar() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      await ProfileService.createProfileIfNeeded();

      final profile = await supabase
          .from('profiles')
          .select('plan')
          .eq('id', user.id)
          .maybeSingle();

      final plan = profile?['plan']?.toString().toLowerCase();

      if (plan != 'pro') {
        throw Exception('PRO subscription required.');
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

      final savedUrl = await saveAvatar(url);

      if (savedUrl == null) {
        throw Exception('Could not save custom avatar URL.');
      }

      debugPrint('CUSTOM AVATAR SAVED: $savedUrl');

      return savedUrl;
    } catch (e, stackTrace) {
      debugPrint('UPLOAD AVATAR ERROR: $e');
      debugPrint('$stackTrace');
      return null;
    }
  }

  // LOAD AVATAR
  static Future<String?> getAvatar() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    try {
      final profile = await supabase
          .from('profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      return profile?['avatar_url']?.toString();
    } catch (e) {
      debugPrint('GET AVATAR ERROR: $e');
      return null;
    }
  }
}
