import 'dart:convert';
import 'package:http/http.dart' as http;

class CryptoService {
  static Future<Map<String, dynamic>> getMarketData() async {
    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd&include_24hr_change=true',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load crypto data');
  }
}