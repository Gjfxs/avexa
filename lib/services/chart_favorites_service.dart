import 'package:shared_preferences/shared_preferences.dart';

class ChartFavoritesService {
  static const String _storageKey = 'avexa_chart_favorites';

  static Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    return (prefs.getStringList(_storageKey) ?? <String>[]).toSet();
  }

  static Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _storageKey,
      favorites.toList()..sort(),
    );
  }

  static String coinKey(String symbol) {
    return 'coin:${symbol.trim().toUpperCase()}';
  }

  static String dexKey(String chainId, String tokenAddress) {
    return 'dex:${chainId.trim().toLowerCase()}:${tokenAddress.trim().toLowerCase()}';
  }
}