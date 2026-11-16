import 'dart:convert';
import 'package:http/http.dart' as http;

class CryptoService {
  static const _url =
      'https://mbwvfjoayhfnsiabrgcf.supabase.co/functions/v1/chat';

  static const _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1id3Zmam9heWhmbnNpYWJyZ2NmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1ODIwNTksImV4cCI6MjA5ODE1ODA1OX0.Fi9N-Jh8e3QwevUXr-ZQlPIrdhFuyyZM8UgL0iMQRnw';

  Future<String> generateReply(
    List<Map<String, String>> messages,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _anonKey,
          'Authorization': 'Bearer $_anonKey',
        },
        body: jsonEncode({
          'messages': messages,
        }),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "No response received.";
      }

      return response.body;
    } catch (e) {
      return "Connection error: $e";
    }
  }
}