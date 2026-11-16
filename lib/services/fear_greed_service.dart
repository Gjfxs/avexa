import 'dart:convert';
import 'package:http/http.dart' as http;

class FearGreedService {
  Future<Map<String, dynamic>> fetchIndex() async {
    final response = await http.get(
      Uri.parse(
        'https://api.alternative.me/fng/',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'][0];
    }

    throw Exception('Failed to load Fear & Greed');
  }
}