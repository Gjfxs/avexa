import 'dart:convert';
import 'package:http/http.dart' as http;

class CoinGeckoService {
  static Future<List<dynamic>> getMarkets() async {
    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/markets'
      '?vs_currency=usd'
      '&order=market_cap_desc'
      '&per_page=100'
      '&page=1'
      '&sparkline=false',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load markets');
  }
  static Future<List<dynamic>> getChart(
    String coinId,
  ) async {

    final response = await http.get(
      Uri.parse(
        'https://api.coingecko.com/api/v3/coins/$coinId/market_chart?vs_currency=usd&days=7',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["prices"];
    }

    throw Exception("Failed to load chart");
  }

  static Future<Map<String, dynamic>> getCoinDetails(
    String coinId,
  ) async {
    final response = await http.get(
      Uri.parse(
        'https://api.coingecko.com/api/v3/coins/$coinId',
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed to load coin details");
  }

  static Future<List<dynamic>> getTrending() async {

    final response = await http.get(
      Uri.parse(
        "https://api.coingecko.com/api/v3/search/trending",
      ),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data["coins"];
    }

    throw Exception("Failed to load trending");
  }

  static Future<List<dynamic>> getChartData(
    String coinId,
  ) async {

    final response = await http.get(
      Uri.parse(
        'https://api.coingecko.com/api/v3/coins/$coinId/market_chart?vs_currency=usd&days=7',
      ),
    );

    final data = jsonDecode(response.body);

    return data["prices"];
  }

}
