import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class MarketService {
  // ============================================================
  // COINGECKO MARKET DATA
  // ============================================================

  Future<List<dynamic>> fetchMarkets() async {
    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/markets'
      '?vs_currency=usd'
      '&order=market_cap_desc'
      '&per_page=20'
      '&page=1'
      '&sparkline=false',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load market data');
  }

  Future<List<dynamic>> fetchTopMovers() async {
    final markets = await fetchMarkets();

    markets.sort(
      (a, b) =>
          (b['price_change_percentage_24h'] ?? 0)
              .compareTo(
        a['price_change_percentage_24h'] ?? 0,
      ),
    );

    return markets.take(3).toList();
  }

  // ============================================================
  // BINANCE FUTURES LIQUIDATIONS
  // ============================================================

  Stream<List<dynamic>> liquidationStream() {
    final channel = WebSocketChannel.connect(
      Uri.parse(
        'wss://fstream.binance.com/ws/!forceOrder@arr',
      ),
    );

    return channel.stream
        .map<List<dynamic>>((message) {
          try {
            final data = jsonDecode(message);

            final liquidation =
                data['o'];

            if (liquidation == null) {
              return [];
            }

            final symbol =
                liquidation['s']?.toString() ?? '';

            final side =
                liquidation['S']?.toString() ?? '';

            final quantity =
                double.tryParse(
                      liquidation['q']
                              ?.toString() ??
                          '',
                    ) ??
                    0;

            final price =
                double.tryParse(
                      liquidation['ap']
                              ?.toString() ??
                          liquidation['p']
                              ?.toString() ??
                          '',
                    ) ??
                    0;

            final value =
                quantity * price;

            return [
              {
                'symbol': symbol,
                'side': side,
                'quantity': quantity,
                'price': price,
                'value': value,
                'time': liquidation['T'],
              },
            ];
          } catch (_) {
            return [];
          }
        })
        .where(
          (items) => items.isNotEmpty,
        );
  }
}