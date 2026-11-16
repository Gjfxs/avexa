import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SavedMessagesService {
  static const _key = "saved_ai_messages";

  Future<List<String>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_key);

    if (data == null) return [];

    return List<String>.from(jsonDecode(data));
  }

  Future<void> saveMessage(String text) async {
    final prefs = await SharedPreferences.getInstance();

    final messages = await loadMessages();

    if (!messages.contains(text)) {
      messages.insert(0, text);
    }

    await prefs.setString(
      _key,
      jsonEncode(messages),
    );
  }

  Future<void> deleteMessage(String text) async {
    final prefs = await SharedPreferences.getInstance();

    final messages = await loadMessages();

    messages.remove(text);

    await prefs.setString(
      _key,
      jsonEncode(messages),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}