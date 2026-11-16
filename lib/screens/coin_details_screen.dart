import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../services/coingecko_service.dart';
import '../services/chart_favorites_service.dart';

class CoinDetailsScreen extends StatefulWidget {
  final String coinId;
  final String pair;
  final String price;
  final String change;
  final Color color;
  final Map<String, dynamic>? dexPair;
  final bool isFavorite;

  const CoinDetailsScreen({
    super.key,
    required this.coinId,
    required this.pair,
    required this.price,
    required this.change,
    required this.color,
    this.dexPair,
    this.isFavorite = false,
  });

  bool get isDex => dexPair != null;

  @override
  State<CoinDetailsScreen> createState() => _CoinDetailsScreenState();
}

class _CoinDetailsScreenState extends State<CoinDetailsScreen> {
  Map<String, dynamic>? coinData;
  bool loading = true;
  bool _isFavorite = false;
  late final WebViewController controller;

  String? get _favoriteKey {
    if (widget.isDex) {
      final chainId = widget.dexPair?['chainId']?.toString();
      final tokenAddress =
          widget.dexPair?['baseToken']?['address']?.toString();

      if (chainId == null ||
          chainId.isEmpty ||
          tokenAddress == null ||
          tokenAddress.isEmpty) {
        return null;
      }

      return ChartFavoritesService.dexKey(
        chainId,
        tokenAddress,
      );
    }

    return ChartFavoritesService.coinKey(widget.pair);
  }

  Future<void> _toggleFavorite() async {
    final key = _favoriteKey;
    if (key == null) return;

    final favorites = await ChartFavoritesService.loadFavorites();
    final wasFavorite = favorites.contains(key);

    if (wasFavorite) {
      favorites.remove(key);
    } else {
      favorites.add(key);
    }

    await ChartFavoritesService.saveFavorites(favorites);

    if (!mounted) return;

    setState(() {
      _isFavorite = !wasFavorite;
    });
  }


  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _loadFavoriteState();
    loadCoinData();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    if (widget.isDex) {
      final url = widget.dexPair?['url']?.toString();
      if (url != null && url.isNotEmpty) {
        controller.loadRequest(Uri.parse(url));
      }
    } else {
      controller.loadHtmlString(_tradingViewHtml());
    }
  }

  Future<void> _loadFavoriteState() async {
    final key = _favoriteKey;
    if (key == null) return;

    final favorites = await ChartFavoritesService.loadFavorites();

    if (!mounted) return;

    setState(() {
      _isFavorite = favorites.contains(key);
    });
  }

  Future<void> loadCoinData() async {
    if (widget.isDex) {
      if (!mounted) return;
      setState(() => loading = false);
      return;
    }

    try {
      final data = await CoinGeckoService.getCoinDetails(widget.coinId);
      if (!mounted) return;
      setState(() {
        coinData = data;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  String _tradingViewHtml() {
    return """
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
html, body {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  background: #070B16;
  overflow: hidden;
}
#tradingview_chart {
  width: 100%;
  height: 100%;
}
</style>
</head>
<body>
<div id="tradingview_chart"></div>
<script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
<script>
new TradingView.widget({
  "studies": [],
  "hide_side_toolbar": true,
  "save_image": false,
  "autosize": true,
  "symbol": "BINANCE:${widget.pair}USDT",
  "interval": "60",
  "timezone": "Etc/UTC",
  "theme": "dark",
  "style": "1",
  "locale": "en",
  "hide_top_toolbar": false,
  "allow_symbol_change": false,
  "container_id": "tradingview_chart"
});
</script>
</body>
</html>
""";
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AvexaColors>()!;

    if (loading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(
          child: CircularProgressIndicator(color: neonBlue),
        ),
      );
    }

    return widget.isDex
        ? _buildDexDetails(colors, l)
        : _buildCoinDetails(colors, l);
  }

  Widget _buildCoinDetails(AvexaColors colors, AppLocalizations l) {
    final marketData = coinData?['market_data'];
    final price = _toDouble(marketData?['current_price']?['usd']);
    final marketCap = _toDouble(marketData?['market_cap']?['usd']);
    final volume = _toDouble(marketData?['total_volume']?['usd']);
    final fdv = _toDouble(marketData?['fully_diluted_valuation']?['usd']);
    final change = _toDouble(marketData?['price_change_percentage_24h']);
    final circulating = _toDouble(marketData?['circulating_supply']);
    final maxSupply = _toDouble(marketData?['max_supply']);
    final supplyPercent = maxSupply > 0 ? circulating / maxSupply * 100 : 0.0;
    final name = coinData?['name']?.toString() ?? widget.pair;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                coinName: name,
                image: coinData?['image']?['small']?.toString(),
                badge: l.coinDetailsCoinBadge,
                colors: colors,
              ),
              const SizedBox(height: 22),
              _buildPriceHeader(
                price: '\$${_formatPrice(price)}',
                name: name,
                change: change,
                colors: colors,
                l: l,
              ),
              const SizedBox(height: 20),
              _buildStatsGrid(
                volume: volume,
                change: change,
                fdv: fdv,
                marketCap: marketCap,
                colors: colors,
                l: l,
              ),
              const SizedBox(height: 20),
              _buildChart(colors, l),
              const SizedBox(height: 20),
              _buildMarketData(colors, l),
              const SizedBox(height: 20),
              _buildSupplyCard(
                circulating: circulating,
                maxSupply: maxSupply,
                percent: supplyPercent,
                colors: colors,
                l: l,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDexDetails(AvexaColors colors, AppLocalizations l) {
    final pair = widget.dexPair!;
    final change = _toDouble(pair['priceChange']?['h24']);
    final marketCap = _toDouble(pair['marketCap']);
    final fdv = _toDouble(pair['fdv']);
    final volume = _toDouble(pair['volume']?['h24']);
    final liquidity = _toDouble(pair['liquidity']?['usd']);
    final buys = pair['txns']?['h24']?['buys'] ?? 0;
    final sells = pair['txns']?['h24']?['sells'] ?? 0;
    final symbol = pair['baseToken']?['symbol']?.toString().toUpperCase()
        ?? widget.pair;
    final name = pair['baseToken']?['name']?.toString() ?? symbol;
    final image = pair['info']?['imageUrl']?.toString();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                coinName: name,
                image: image,
                badge: l.coinDetailsDexBadge,
                colors: colors,
              ),
              const SizedBox(height: 22),
              _buildPriceHeader(
                price: '\$${pair['priceUsd'] ?? '-'}',
                name: name,
                change: change,
                colors: colors,
                l: l,
              ),
              const SizedBox(height: 20),
              _buildStatsGrid(
                volume: volume,
                change: change,
                fdv: fdv,
                marketCap: marketCap,
                liquidity: liquidity,
                colors: colors,
                l: l,
              ),
              const SizedBox(height: 20),
              _buildDexPairInfo(
                pair: pair,
                buys: buys,
                sells: sells,
                colors: colors,
                l: l,
              ),
              const SizedBox(height: 20),
              _buildChart(colors, l),
              const SizedBox(height: 20),
              _buildDexMetrics(
                liquidity: liquidity,
                volume: volume,
                marketCap: marketCap,
                fdv: fdv,
                colors: colors,
                l: l,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String coinName,
    required String? image,
    required String badge,
    required AvexaColors colors,
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context, _isFavorite),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.card,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: colors.primaryText,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (image != null && image.isNotEmpty)
          _coinImage(image, 42)
        else
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.token_rounded, color: neonBlue),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.pair,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                coinName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: colors.mutedText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: neonBlue.withOpacity(.10),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: neonBlue.withOpacity(.20)),
          ),
          child: Text(
            badge,
            style: GoogleFonts.poppins(
              color: neonBlue,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _toggleFavorite,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _isFavorite ? neonYellow.withOpacity(.12) : colors.card,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isFavorite ? neonYellow : colors.border,
              ),
              boxShadow: _isFavorite
                  ? [BoxShadow(color: neonBlue.withOpacity(.10), blurRadius: 12)]
                  : null,
            ),
            child: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: _isFavorite ? neonYellow : colors.mutedText,
              size: 21,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceHeader({
    required String price,
    required String name,
    required double change,
    required AvexaColors colors,
    required AppLocalizations l,
  }) {
    final color = change >= 0 ? neonGreen : neonRed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(color: neonBlue.withOpacity(.055), blurRadius: 24),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.coinDetailsCurrentPrice,
            style: GoogleFonts.poppins(color: colors.mutedText, fontSize: 11),
          ),
          const SizedBox(height: 5),
          Text(
            price,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 31,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            name,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: color.withOpacity(.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(.20)),
                ),
                child: Row(
                  children: [
                    Icon(
                      change >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: color,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                      style: GoogleFonts.poppins(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l.coinDetails24H,
                style: GoogleFonts.poppins(color: colors.mutedText, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid({
    required double volume,
    required double change,
    required double fdv,
    required double marketCap,
    double? liquidity,
    required AvexaColors colors,
    required AppLocalizations l,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.75,
      children: [
        _statCard(
          l.coinDetails24HVolume,
          _formatMoney(volume),
          Icons.bar_chart_rounded,
          colors: colors,
        ),
        _statCard(
          l.coinDetails24HChange,
          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
          Icons.show_chart_rounded,
          valueColor: change >= 0 ? neonGreen : neonRed,
          colors: colors,
        ),
        _statCard(
          widget.isDex ? l.coinDetailsLiquidity : l.coinDetailsFdv,
          widget.isDex ? _formatMoney(liquidity ?? 0) : _formatMoney(fdv),
          Icons.water_drop_outlined,
          colors: colors,
        ),
        _statCard(
          l.coinDetailsMarketCap,
          _formatMoney(marketCap),
          Icons.account_balance_rounded,
          colors: colors,
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon, {
    Color? valueColor,
    required AvexaColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.09),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: neonBlue, size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: colors.mutedText,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: valueColor ?? colors.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(AvexaColors colors, AppLocalizations l) {
    return Container(
      height: 390,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(color: neonBlue.withOpacity(.055), blurRadius: 24),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.candlestick_chart_rounded,
                  color: neonBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  l.coinDetailsPriceChart,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  '1H',
                  style: GoogleFonts.poppins(
                    color: colors.mutedText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: WebViewWidget(controller: controller)),
        ],
      ),
    );
  }

  Widget _buildMarketData(AvexaColors colors, AppLocalizations l) {
    final data = coinData?['market_data'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.analytics_outlined, l.coinDetailsMarketData, colors),
          const SizedBox(height: 20),
          _dataRow(l.coinDetails24HHigh, '\$${_formatPrice(data?['high_24h']?['usd'])}', colors: colors),
          _dataRow(l.coinDetails24HLow, '\$${_formatPrice(data?['low_24h']?['usd'])}', colors: colors),
          _dataRow(l.coinDetailsAllTimeHigh, '\$${_formatPrice(data?['ath']?['usd'])}', valueColor: neonGreen, colors: colors),
          _dataRow(l.coinDetailsAllTimeLow, '\$${_formatPrice(data?['atl']?['usd'])}', valueColor: neonRed, colors: colors),
          const SizedBox(height: 10),
          Divider(color: colors.border),
          const SizedBox(height: 10),
          _dataRow(l.coinDetailsMarketCapRank, '#${coinData?['market_cap_rank'] ?? '-'}', valueColor: neonBlue, colors: colors),
          _dataRow(l.coinDetailsCirculatingSupply, _formatSupply(data?['circulating_supply']), colors: colors),
          _dataRow(l.coinDetailsTotalSupply, _formatSupply(data?['total_supply']), colors: colors),
          _dataRow(l.coinDetailsMaxSupply, _formatSupply(data?['max_supply']), colors: colors),
        ],
      ),
    );
  }

  Widget _buildSupplyCard({
    required double circulating,
    required double maxSupply,
    required double percent,
    required AvexaColors colors,
    required AppLocalizations l,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.pie_chart_outline_rounded, l.coinDetailsSupply, colors),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '${percent.clamp(0, 100).toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  color: neonBlue,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.coinDetailsInCirculation,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: colors.border,
              valueColor: const AlwaysStoppedAnimation(neonBlue),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.coinDetailsCirculatingAmount(_formatSupply(circulating)),
            style: GoogleFonts.poppins(
              color: colors.mutedText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDexPairInfo({
    required Map<String, dynamic> pair,
    required dynamic buys,
    required dynamic sells,
    required AvexaColors colors,
    required AppLocalizations l,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.account_tree_rounded, l.coinDetailsDexPair, colors),
          const SizedBox(height: 20),
          _dataRow(l.coinDetailsNetwork, _chainName(pair['chainId']), valueColor: neonBlue, colors: colors),
          _dataRow(l.coinDetailsDex, pair['dexId']?.toString() ?? '-', colors: colors),
          _dataRow(l.coinDetailsPair, pair['pairAddress']?.toString() ?? '-', colors: colors),
          _dataRow(l.coinDetails24HBuys, buys.toString(), valueColor: neonGreen, colors: colors),
          _dataRow(l.coinDetails24HSells, sells.toString(), valueColor: neonRed, colors: colors),
          _dataRow(l.coinDetailsPairAge, _pairAge(pair['pairCreatedAt'], l), colors: colors),
        ],
      ),
    );
  }

  Widget _buildDexMetrics({
    required double liquidity,
    required double volume,
    required double marketCap,
    required double fdv,
    required AvexaColors colors,
    required AppLocalizations l,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.insights_rounded, l.coinDetailsDexMetrics, colors),
          const SizedBox(height: 18),
          _dataRow(l.coinDetailsLiquidity, _formatMoney(liquidity), colors: colors),
          _dataRow(l.coinDetails24HVolume, _formatMoney(volume), colors: colors),
          _dataRow(l.coinDetailsMarketCap, _formatMoney(marketCap), colors: colors),
          _dataRow(l.coinDetailsFdv, _formatMoney(fdv), colors: colors),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: neonBlue.withOpacity(.14)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: neonBlue, size: 17),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.coinDetailsDexSourceNotice,
                    style: GoogleFonts.poppins(
                      color: colors.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title, AvexaColors colors) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: neonBlue.withOpacity(.09),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: neonBlue, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dataRow(
    String title,
    String value, {
    Color? valueColor,
    required AvexaColors colors,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                color: valueColor ?? colors.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coinImage(String? url, double size) {
    if (url == null || url.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: neonBlue.withOpacity(.10),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.token_rounded, color: neonBlue, size: 20),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: neonBlue.withOpacity(.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.token_rounded, color: neonBlue),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(AvexaColors colors) {
    return BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: colors.border),
      boxShadow: [
        BoxShadow(color: neonBlue.withOpacity(.04), blurRadius: 20),
      ],
    );
  }

  String _formatMoney(dynamic value) {
    final number = _toDouble(value);
    if (number >= 1000000000) return '\$${(number / 1000000000).toStringAsFixed(2)}B';
    if (number >= 1000000) return '\$${(number / 1000000).toStringAsFixed(2)}M';
    if (number >= 1000) return '\$${(number / 1000).toStringAsFixed(1)}K';
    return '\$${number.toStringAsFixed(0)}';
  }

  String _formatPrice(dynamic value) {
    final number = _toDouble(value);
    if (number >= 1000) return number.toStringAsFixed(2);
    if (number >= 1) return number.toStringAsFixed(4);
    if (number >= .01) return number.toStringAsFixed(6);
    return number.toStringAsFixed(10);
  }

  String _formatSupply(dynamic value) {
    final number = _toDouble(value);
    if (number >= 1000000000) return '${(number / 1000000000).toStringAsFixed(2)}B';
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(2)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toStringAsFixed(0);
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _chainName(dynamic chain) {
    switch (chain?.toString()) {
      case 'solana':
        return 'Solana';
      case 'ethereum':
        return 'Ethereum';
      case 'base':
        return 'Base';
      case 'arbitrum':
        return 'Arbitrum';
      case 'bsc':
        return 'BSC';
      default:
        return chain?.toString() ?? '-';
    }
  }

  String _pairAge(dynamic timestamp, AppLocalizations l) {
    if (timestamp == null) return '-';

    final created = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(timestamp.toString()) ?? 0,
    );
    final difference = DateTime.now().difference(created);

    if (difference.inDays > 0) {
      return l.coinDetailsDays(difference.inDays);
    }
    if (difference.inHours > 0) {
      return l.coinDetailsHours(difference.inHours);
    }
    return l.coinDetailsMinutes(difference.inMinutes);
  }
}
