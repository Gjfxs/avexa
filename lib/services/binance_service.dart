import 'dart:convert';
import 'package:http/http.dart' as http;

class CandleData {
  final double open;
  final double high;
  final double low;
  final double close;

  CandleData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}

class BinanceService {

  static Future<List<CandleData>> getCandles(
    String symbol,
  ) async {

    final response = await http.get(
      Uri.parse(
        "https://api.binance.com/api/v3/klines"
        "?symbol=${symbol}USDT"
        "&interval=1h"
        "&limit=100",
      ),
    );

    final List data = jsonDecode(response.body);

    return data.map((e) {

      return CandleData(
        open: double.parse(e[1]),
        high: double.parse(e[2]),
        low: double.parse(e[3]),
        close: double.parse(e[4]),
      );

    }).toList();
  }
}