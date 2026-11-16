import 'dart:convert';
import 'package:http/http.dart' as http;

class DexScreenerService {
  static const String baseUrl = 'https://api.dexscreener.com';

  static Future<List<Map<String, dynamic>>> getTrendingPairs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/metas/trending/v1'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'DexScreener error: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      return [];
    }

    final metas = decoded
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .where(
          (item) =>
              item['slug'] != null &&
              item['slug'].toString().isNotEmpty,
        )
        .take(12)
        .toList();

    final results = <Map<String, dynamic>>[];

    for (final meta in metas) {
      try {
        final slug = meta['slug'].toString();

        final pairResponse = await http.get(
          Uri.parse(
            '$baseUrl/metas/meta/v1/${Uri.encodeComponent(slug)}',
          ),
        );

        if (pairResponse.statusCode != 200) {
          continue;
        }

        final pairDecoded = jsonDecode(pairResponse.body);

        if (pairDecoded is! Map) {
          continue;
        }

        final pairs = pairDecoded['pairs'];

        if (pairs is! List) {
          continue;
        }

        for (final rawPair in pairs) {
          if (rawPair is! Map) continue;

          final pair = Map<String, dynamic>.from(rawPair);

          final marketCap =
              _toDouble(pair['marketCap']);

          final liquidity =
              _toDouble(pair['liquidity']?['usd']);

          final volume =
              _toDouble(pair['volume']?['h24']);

          if (marketCap <= 0 &&
              liquidity <= 0 &&
              volume <= 0) {
            continue;
          }

          results.add(pair);
        }
      } catch (_) {
        continue;
      }
    }

    final unique = <String, Map<String, dynamic>>{};

    for (final pair in results) {
      final address =
          pair['pairAddress']?.toString();

      if (address == null || address.isEmpty) {
        continue;
      }

      unique[address] = pair;
    }

    final finalPairs = unique.values.toList();

    finalPairs.sort(
      (a, b) {
        final volumeA =
            _toDouble(a['volume']?['h24']);

        final volumeB =
            _toDouble(b['volume']?['h24']);

        return volumeB.compareTo(volumeA);
      },
    );

    return finalPairs;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }
}