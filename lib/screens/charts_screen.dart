import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/coingecko_service.dart';
import '../services/dexscreener_service.dart';
import 'coin_details_screen.dart';
import '../widgets/app_page_header.dart';
import '../l10n/app_localizations.dart';
import '../services/chart_favorites_service.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});
  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  String selectedCategory = "Trending";
  String searchQuery = "";
  String moversMode = "Gainers";
  String sortMode = "Market Cap";
  bool _sortMenuOpen = false;
  Set<String> favorites = {};
  List<dynamic> liveCoins = [];
  List<dynamic> trendingCoins = [];
  List<Map<String, dynamic>> dexPairs = [];
  bool isLoading = true;
  bool isDexLoading = false;
  String dexChain = "All Chains";
  String dexMarketCap = "All";
  String dexVolume = "All";
  String dexLiquidity = "All";
  String dexChange = "All";
  String dexAge = "All";
  String dexSort = "Volume";
  bool dexLoaded = false;
  final searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadFavorites();
    loadCoins();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final savedFavorites =
        await ChartFavoritesService.loadFavorites();

    if (!mounted) return;

    setState(() {
      favorites = savedFavorites;
    });
  }

  Future<void> loadCoins() async {
    try {
      final data = await CoinGeckoService.getMarkets();
      final trending = await CoinGeckoService.getTrending();
      if (!mounted) return;
      setState(() {
        liveCoins = data;
        trendingCoins = trending;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadDexPairs() async {
    if (isDexLoading) return;
    setState(() {
      isDexLoading = true;
    });
    try {
      final data = await DexScreenerService.getTrendingPairs();
      if (!mounted) return;
      setState(() {
        dexPairs = data;
        dexLoaded = true;
        isDexLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() {
        dexLoaded = true;
        isDexLoading = false;
      });
    }
  }

  Future<void> _selectCategory(String category) async {
    setState(() {
      if (category == "Favorites" && selectedCategory == "Favorites") {
        selectedCategory = "Trending";
      } else {
        selectedCategory = category;
      }
    });
    if ((category == "DEX" || category == "Favorites") &&
        !dexLoaded) {
      await loadDexPairs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    if (isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator(color: neonBlue)),
      );
    }
    final sortedCoins = [...liveCoins];
    if (sortMode == "Market Cap") {
      sortedCoins.sort(
        (a, b) => (b["market_cap"] ?? 0).compareTo(a["market_cap"] ?? 0),
      );
    }
    if (sortMode == "Volume") {
      sortedCoins.sort(
        (a, b) => (b["total_volume"] ?? 0).compareTo(a["total_volume"] ?? 0),
      );
    }
    if (sortMode == "24H Change") {
      sortedCoins.sort(
        (a, b) => (b["price_change_percentage_24h"] ?? 0).compareTo(
          a["price_change_percentage_24h"] ?? 0,
        ),
      );
    }
    if (sortMode == "Rank") {
      sortedCoins.sort(
        (a, b) => (a["market_cap_rank"] ?? 9999).compareTo(
          b["market_cap_rank"] ?? 9999,
        ),
      );
    }
    return Scaffold(
      extendBody: true,
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          color: neonBlue,
          backgroundColor: colors.card,
          onRefresh: () async {
            await loadCoins();
            if (selectedCategory == "DEX") {
              await loadDexPairs();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppPageHeader(title: l10n.chartsTitle),
                const SizedBox(height: 24),
                _buildSearch(colors),
                const SizedBox(height: 16),
                if (selectedCategory != "DEX") _buildMarketSort(colors),
                if (selectedCategory != "DEX") const SizedBox(height: 18),
                _buildCategories(colors),
                const SizedBox(height: 24),
                if (selectedCategory == "DEX")
                  _buildDexSection(colors)
                else
                  _buildMarketSection(sortedCoins, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // SEARCH
  // ================================================================
  Widget _buildSearch(AvexaColors colors) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(.055),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value.trim().toLowerCase();
          });
        },
        style: GoogleFonts.poppins(color: colors.primaryText, fontSize: 14),
        cursorColor: neonBlue,
        decoration: InputDecoration(
          hintText: l10n.chartsSearchHint,
          hintStyle: GoogleFonts.poppins(color: colors.mutedText, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: neonBlue),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchQuery = "";
                    });
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.mutedText,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  // ================================================================
  // MARKET SORT
  // ================================================================
  Widget _buildMarketSort(AvexaColors colors) {
    const double menuWidth = 355;
    return Center(
      child: SizedBox(
        width: menuWidth,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _sortMenuOpen = !_sortMenuOpen;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                height: 56,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: _sortMenuOpen
                      ? const BorderRadius.vertical(top: Radius.circular(20))
                      : BorderRadius.circular(20),
                  border: Border.all(
                    color: neonBlue.withOpacity(.28),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonBlue.withOpacity(.035),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sort_rounded, color: neonBlue, size: 23),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _sortLabel(sortMode),
                        style: GoogleFonts.poppins(
                          color: colors.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _sortMenuOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colors.secondaryText,
                        size: 23,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 180),
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeOutCubic,
              sizeCurve: Curves.easeOutCubic,
              crossFadeState: _sortMenuOpen
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.elevatedCard,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  border: Border(
                    left: BorderSide(
                      color: neonBlue.withOpacity(.28),
                      width: 1.2,
                    ),
                    right: BorderSide(
                      color: neonBlue.withOpacity(.28),
                      width: 1.2,
                    ),
                    bottom: BorderSide(
                      color: neonBlue.withOpacity(.28),
                      width: 1.2,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonBlue.withOpacity(.08),
                      blurRadius: 24,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _sortMenuItem("Market Cap", colors),
                    _sortMenuItem("Volume", colors),
                    _sortMenuItem("24H Change", colors),
                    _sortMenuItem("Rank", colors),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortMenuItem(String value, AvexaColors colors) {
    final selected = sortMode == value;
    return InkWell(
      onTap: () {
        setState(() {
          sortMode = value;
          _sortMenuOpen = false;
        });
      },
      child: Container(
        height: 64,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 4,
              height: selected ? 24 : 0,
              decoration: BoxDecoration(
                color: neonBlue,
                borderRadius: BorderRadius.circular(4),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: neonBlue.withOpacity(.45),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            ),
            SizedBox(width: selected ? 14 : 18),
            Text(
              _sortLabel(value),
              style: GoogleFonts.poppins(
                color: selected ? neonBlue : colors.primaryText,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_rounded, color: neonBlue, size: 19),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // CATEGORIES
  // ================================================================
  Widget _buildCategories(AvexaColors colors) {
    final categories = [
      {"title": "Favorites", "icon": Icons.star_rounded},
      {"title": "DEX", "icon": Icons.account_tree_rounded},
      {"title": "Trending", "icon": Icons.trending_up_rounded},
      {"title": "Spot", "icon": Icons.candlestick_chart_rounded},
      {"title": "Futures", "icon": Icons.show_chart_rounded},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((item) {
          final title = item["title"] as String;
          final active = selectedCategory == title;
          if (title == "Favorites") {
            return GestureDetector(
              onTap: () => _selectCategory(title),
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.only(right: 9),
                decoration: BoxDecoration(
                  color: active ? Colors.amber.withOpacity(.12) : colors.card,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? Colors.amber : colors.border,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: Colors.amber.withOpacity(.10),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  active ? Icons.star_rounded : Icons.star_border_rounded,
                  color: active ? Colors.amber : Colors.amber.withOpacity(.70),
                  size: 21,
                ),
              ),
            );
          }
          return GestureDetector(
            onTap: () => _selectCategory(title),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(right: 9),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              decoration: BoxDecoration(
                color: active ? neonBlue.withOpacity(.13) : colors.card,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: active ? neonBlue : colors.border),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: neonBlue.withOpacity(.10),
                          blurRadius: 14,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    item["icon"] as IconData,
                    size: 17,
                    color: active ? neonBlue : colors.mutedText,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    _categoryLabel(title),
                    style: GoogleFonts.poppins(
                      color: active ? neonBlue : colors.secondaryText,
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================================================================
  // MARKET SECTION
  // ================================================================
  Widget _buildMarketSection(List<dynamic> sortedCoins, AvexaColors colors) {
    if (selectedCategory != "Favorites") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopMoversSection(colors),
          const SizedBox(height: 22),
          _sectionHeader(
            selectedCategory == "Trending"
                ? l10n.chartsTrendingCoins
                : selectedCategory == "Spot"
                ? l10n.chartsSpotMarket
                : l10n.chartsFuturesMarket,
            selectedCategory == "Trending"
                ? l10n.chartsMostActive
                : selectedCategory == "Spot"
                ? l10n.chartsSpotAssets
                : l10n.chartsFuturesAssets,
            colors,
          ),
          const SizedBox(height: 14),
          ...sortedCoins
              .where(_matchesCoin)
              .take(selectedCategory == "Trending" ? 7 : 5)
              .map(
                (coin) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: chartCard(
                    coin,
                    favorites.contains(
                      ChartFavoritesService.coinKey(
                        (coin["symbol"] as String).toUpperCase(),
                      ),
                    ),
                    colors,
                  ),
                ),
              ),
        ],
      );
    }
    if (selectedCategory == "Favorites") {
      final favoriteDexPairs = dexPairs.where((pair) {
        final address =
            pair["baseToken"]?["address"]?.toString() ?? "";

        if (address.isEmpty) return false;

        final key = ChartFavoritesService.dexKey(
          pair["chainId"]?.toString() ?? "",
          address,
        );

        final symbol =
            pair["baseToken"]?["symbol"]?.toString().toLowerCase() ?? "";

        final name =
            pair["baseToken"]?["name"]?.toString().toLowerCase() ?? "";

        return favorites.contains(key) &&
            (symbol.contains(searchQuery) || name.contains(searchQuery));
      }).toList();

      final favoriteCoins = sortedCoins.where((coin) {
        final symbol = (coin["symbol"] as String).toUpperCase();

        return favorites.contains(ChartFavoritesService.coinKey(symbol)) &&
            symbol.toLowerCase().contains(searchQuery);
      }).toList();

      if (favoriteCoins.isEmpty && favoriteDexPairs.isEmpty) {
        return _emptyFavorites(colors);
      }

      return Column(
        children: [
          ...favoriteCoins.map(
            (coin) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: chartCard(coin, true, colors),
            ),
          ),
          ...favoriteDexPairs.map(
            (pair) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _dexCard(pair, colors),
            ),
          ),
        ],
      );
    }
    final favoriteCoins = sortedCoins.where((coin) {
      final symbol = (coin["symbol"] as String).toUpperCase();
      final favoriteKey = ChartFavoritesService.coinKey(symbol);

      return favorites.contains(favoriteKey) &&
          symbol.toLowerCase().contains(searchQuery);
    }).toList();
    if (favoriteCoins.isEmpty) {
      return _emptyFavorites(colors);
    }
    return Column(
      children: favoriteCoins
          .map(
            (coin) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: chartCard(coin, true, colors),
            ),
          )
          .toList(),
    );
  }

  // ================================================================
  // MARKET FILTERING
  // ================================================================
  bool _matchesCoin(dynamic coin) {
    final symbol = (coin["symbol"] as String).toUpperCase();
    if (!symbol.toLowerCase().contains(searchQuery)) {
      return false;
    }
    if (selectedCategory == "Trending") {
      return trendingCoins.any(
        (item) => item["item"]["symbol"].toString().toUpperCase() == symbol,
      );
    }
    if (selectedCategory == "Spot") {
      return true;
    }
    if (selectedCategory == "Futures") {
      return [
        "BTC",
        "ETH",
        "SOL",
        "BNB",
        "XRP",
        "DOGE",
        "ADA",
        "SUI",
        "AVAX",
        "LINK",
      ].contains(symbol);
    }
    return true;
  }

  // ================================================================
  // TOP MOVERS
  // ================================================================
  Widget _buildTopMoversSection(AvexaColors colors) {
    final movers = [...liveCoins];
    movers.sort((a, b) {
      final aChange = a["price_change_percentage_24h"] ?? 0;
      final bChange = b["price_change_percentage_24h"] ?? 0;
      return moversMode == "Gainers"
          ? bChange.compareTo(aChange)
          : aChange.compareTo(bChange);
    });
    final filtered = movers.where(_matchesCoin).take(8).toList();
    return buildMoversCard(
      moversMode == "Gainers" ? l10n.chartsTopGainers : l10n.chartsTopLosers,
      filtered,
      colors,
    );
  }

  Widget buildMoversCard(
    String title,
    List<dynamic> coins,
    AvexaColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(color: neonBlue.withOpacity(.045), blurRadius: 22),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: neonBlue.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: neonBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _categoryLabel(title),
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.charts24HourPerformance,
                      style: GoogleFonts.poppins(
                        color: colors.mutedText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _moverToggle("Gainers", neonGreen, colors)),
              const SizedBox(width: 10),
              Expanded(child: _moverToggle("Losers", neonRed, colors)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 235,
            child: ListView.builder(
              itemCount: coins.length,
              itemBuilder: (_, index) {
                final coin = coins[index];
                final change = (coin["price_change_percentage_24h"] ?? 0)
                    .toDouble();
                final color = change >= 0 ? neonGreen : neonRed;
                return GestureDetector(
                  onTap: () => _openCoin(coin),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        _coinImage(coin["image"], 28, colors),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (coin["symbol"] as String).toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: colors.primaryText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                coin["name"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: colors.mutedText,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "\$${coin["current_price"]}",
                          style: GoogleFonts.poppins(
                            color: colors.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${change >= 0 ? "+" : ""}${change.toStringAsFixed(2)}%",
                          style: GoogleFonts.poppins(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _moverToggle(String title, Color color, AvexaColors colors) {
    final active = moversMode == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          moversMode = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(.10) : colors.background,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: active ? color.withOpacity(.28) : colors.border,
          ),
        ),
        child: Center(
          child: Text(
            _categoryLabel(title),
            style: GoogleFonts.poppins(
              color: active ? color : colors.mutedText,
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // SECTION HEADER
  // ================================================================
  Widget _sectionHeader(String title, String subtitle, AvexaColors colors) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: colors.mutedText, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // COIN CARD
  // ================================================================
  Widget chartCard(dynamic coin, bool isFavorite, AvexaColors colors) {
    final pair = (coin["symbol"] as String).toUpperCase();
    final change = (coin["price_change_percentage_24h"] ?? 0).toDouble();
    final color = change >= 0 ? neonGreen : neonRed;
    return GestureDetector(
      onTap: () => _openCoin(coin),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(color: neonBlue.withOpacity(.045), blurRadius: 20),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _coinImage(coin["image"], 44, colors),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pair,
                        style: GoogleFonts.poppins(
                          color: colors.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        coin["name"],
                        style: GoogleFonts.poppins(
                          color: colors.mutedText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final favoriteKey =
                        ChartFavoritesService.coinKey(pair);

                    final updatedFavorites = Set<String>.from(favorites);

                    if (updatedFavorites.contains(favoriteKey)) {
                      updatedFavorites.remove(favoriteKey);
                    } else {
                      updatedFavorites.add(favoriteKey);
                    }

                    setState(() {
                      favorites = updatedFavorites;
                    });

                    await ChartFavoritesService.saveFavorites(
                      updatedFavorites,
                    );
                  },
                  child: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isFavorite
                        ? Colors.amber
                        : Colors.amber.withOpacity(.65),
                    size: 23,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.10),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: color.withOpacity(.20)),
                  ),
                  child: Text(
                    "${change >= 0 ? "+" : ""}${change.toStringAsFixed(2)}%",
                    style: GoogleFonts.poppins(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _infoValue(
                    l10n.chartsPrice,
                    "\$${coin["current_price"]}",
                    colors,
                  ),
                ),
                Expanded(
                  child: _infoValue(
                    l10n.chartsVolume,
                    _formatMoney(coin["total_volume"]),
                    colors,
                  ),
                ),
                Expanded(
                  child: _infoValue(
                    l10n.chartsMarketCapShort,
                    _formatMoney(coin["market_cap"]),
                    colors,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: neonBlue, size: 17),
                  const SizedBox(width: 8),
                  Text(
                    l10n.chartsAiMarketScore,
                    style: GoogleFonts.poppins(
                      color: colors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${((change.abs() / 15) * 100).clamp(0, 100).toStringAsFixed(0)}/100",
                    style: GoogleFonts.poppins(
                      color: neonBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoValue(String title, String value, AvexaColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _categoryLabel(title),
          style: GoogleFonts.poppins(color: colors.mutedText, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // FAVORITES
  // ================================================================
  Widget _emptyFavorites(AvexaColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_border_rounded,
              color: Colors.amber,
              size: 31,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.chartsNoFavorites,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.chartsAddFavoritesHint,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // DEX
  // ================================================================
  Widget _buildDexSection(AvexaColors colors) {
    if (isDexLoading) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: _cardDecoration(colors),
        child: const Center(child: CircularProgressIndicator(color: neonBlue)),
      );
    }
    final filtered = _filteredDexPairs();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDexHeader(colors),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          _emptyDexState(colors)
        else
          ...filtered.map(
            (pair) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _dexCard(pair, colors),
            ),
          ),
      ],
    );
  }

  Widget _buildDexHeader(AvexaColors colors) {
    final activeFilters = [
      dexMarketCap,
      dexVolume,
      dexLiquidity,
      dexChange,
      dexAge,
    ].where((x) => x != "All").length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: neonBlue.withOpacity(.10),
                shape: BoxShape.circle,
                border: Border.all(color: neonBlue.withOpacity(.20)),
              ),
              child: const Icon(
                Icons.account_tree_rounded,
                color: neonBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chartsDexScanner,
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.chartsDexSubtitle,
                    style: GoogleFonts.poppins(
                      color: colors.mutedText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _showDexFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: activeFilters > 0 ? neonBlue : colors.border,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: neonBlue, size: 17),
                    const SizedBox(width: 6),
                    Text(
                      activeFilters > 0
                          ? l10n.chartsFiltersCount(activeFilters)
                          : l10n.chartsFilters,
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _dexChainChip("All Chains", colors),
              _dexChainChip("Solana", colors),
              _dexChainChip("Ethereum", colors),
              _dexChainChip("Base", colors),
              _dexChainChip("Arbitrum", colors),
              _dexChainChip("BSC", colors),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _dexSortButton(colors)),
            const SizedBox(width: 10),
            Text(
              l10n.chartsDexPairsCount(_filteredDexPairs().length),
              style: GoogleFonts.poppins(color: colors.mutedText, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dexChainChip(String chain, AvexaColors colors) {
    final active = dexChain == chain;
    return GestureDetector(
      onTap: () {
        setState(() {
          dexChain = chain;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: active ? neonBlue.withOpacity(.12) : colors.card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: active ? neonBlue : colors.border),
        ),
        child: Text(
          chain == "All Chains" ? l10n.chartsAllChains : chain,
          style: GoogleFonts.poppins(
            color: active ? neonBlue : colors.secondaryText,
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _dexSortButton(AvexaColors colors) {
    return PopupMenuButton<String>(
      color: colors.elevatedCard,
      onSelected: (value) {
        setState(() {
          dexSort = value;
        });
      },
      itemBuilder: (_) => ["Volume", "Liquidity", "Market Cap", "24H Change"]
          .map(
            (item) => PopupMenuItem(
              value: item,
              child: Text(
                _sortLabel(item),
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 13,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort_rounded, color: neonBlue, size: 17),
            const SizedBox(width: 7),
            Text(
              l10n.chartsSortLabel(_sortLabel(dexSort)),
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filteredDexPairs() {
    final result = dexPairs.where((pair) {
      final chain = _chainName(pair["chainId"]);
      if (dexChain != "All Chains" && chain != dexChain) {
        return false;
      }
      final symbol =
          pair["baseToken"]?["symbol"]?.toString().toLowerCase() ?? "";
      final name = pair["baseToken"]?["name"]?.toString().toLowerCase() ?? "";
      if (searchQuery.isNotEmpty &&
          !symbol.contains(searchQuery) &&
          !name.contains(searchQuery)) {
        return false;
      }
      final marketCap = _toDouble(pair["marketCap"]);
      final volume = _toDouble(pair["volume"]?["h24"]);
      final liquidity = _toDouble(pair["liquidity"]?["usd"]);
      final change = _toDouble(pair["priceChange"]?["h24"]);
      if (!_matchRange(marketCap, dexMarketCap, type: "mc")) {
        return false;
      }
      if (!_matchRange(volume, dexVolume, type: "volume")) {
        return false;
      }
      if (!_matchRange(liquidity, dexLiquidity, type: "liquidity")) {
        return false;
      }
      if (!_matchChange(change, dexChange)) {
        return false;
      }
      if (!_matchAge(pair["pairCreatedAt"], dexAge)) {
        return false;
      }
      return true;
    }).toList();
    result.sort((a, b) {
      switch (dexSort) {
        case "Liquidity":
          return _toDouble(
            b["liquidity"]?["usd"],
          ).compareTo(_toDouble(a["liquidity"]?["usd"]));
        case "Market Cap":
          return _toDouble(b["marketCap"]).compareTo(_toDouble(a["marketCap"]));
        case "24H Change":
          return _toDouble(
            b["priceChange"]?["h24"],
          ).compareTo(_toDouble(a["priceChange"]?["h24"]));
        default:
          return _toDouble(
            b["volume"]?["h24"],
          ).compareTo(_toDouble(a["volume"]?["h24"]));
      }
    });
    return result.take(30).toList();
  }

  bool _matchRange(double value, String filter, {required String type}) {
    if (filter == "All") return true;
    if (type == "mc") {
      if (filter == "< \$50K") return value < 50000;
      if (filter == "\$50K – \$250K") {
        return value >= 50000 && value < 250000;
      }
      if (filter == "\$250K – \$1M") {
        return value >= 250000 && value < 1000000;
      }
      if (filter == "\$1M – \$10M") {
        return value >= 1000000 && value < 10000000;
      }
      if (filter == "> \$10M") {
        return value >= 10000000;
      }
    }
    if (type == "volume") {
      if (filter == "> \$25K") {
        return value >= 25000;
      }
      if (filter == "> \$100K") {
        return value >= 100000;
      }
      if (filter == "> \$500K") {
        return value >= 500000;
      }
      if (filter == "> \$1M") {
        return value >= 1000000;
      }
    }
    if (type == "liquidity") {
      if (filter == "> \$10K") {
        return value >= 10000;
      }
      if (filter == "> \$50K") {
        return value >= 50000;
      }
      if (filter == "> \$250K") {
        return value >= 250000;
      }
      if (filter == "> \$1M") {
        return value >= 1000000;
      }
    }
    return true;
  }

  bool _matchChange(double value, String filter) {
    if (filter == "All") return true;
    if (filter == "> +20%") {
      return value >= 20;
    }
    if (filter == "> +10%") {
      return value >= 10;
    }
    if (filter == "0% – +10%") {
      return value >= 0 && value < 10;
    }
    if (filter == "< 0%") {
      return value < 0;
    }
    return true;
  }

  bool _matchAge(dynamic timestamp, String filter) {
    if (filter == "All") return true;
    if (timestamp == null) {
      return false;
    }
    final created = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(timestamp.toString()) ?? 0,
    );
    final age = DateTime.now().difference(created);
    if (filter == "< 1H") {
      return age.inMinutes < 60;
    }
    if (filter == "< 6H") {
      return age.inHours < 6;
    }
    if (filter == "< 24H") {
      return age.inHours < 24;
    }
    if (filter == "< 7D") {
      return age.inDays < 7;
    }
    return true;
  }

  // ================================================================
  // DEX FILTERS
  // ================================================================
  Future<void> _showDexFilters() async {
    String tempMC = dexMarketCap;
    String tempVolume = dexVolume;
    String tempLiquidity = dexLiquidity;
    String tempChange = dexChange;
    String tempAge = dexAge;
    final colors = Theme.of(context).extension<AvexaColors>()!;
    await showModalBottomSheet(
      context: context,
      backgroundColor: colors.elevatedCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.chartsDexFilters,
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.chartsDexFiltersSubtitle,
                      style: GoogleFonts.poppins(
                        color: colors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _filterGroup(
                      "Market Cap",
                      [
                        "All",
                        "< \$50K",
                        "\$50K – \$250K",
                        "\$250K – \$1M",
                        "\$1M – \$10M",
                        "> \$10M",
                      ],
                      tempMC,
                      (value) {
                        setModalState(() {
                          tempMC = value;
                        });
                      },
                      colors,
                    ),
                    _filterGroup(
                      "24H Volume",
                      ["All", "> \$25K", "> \$100K", "> \$500K", "> \$1M"],
                      tempVolume,
                      (value) {
                        setModalState(() {
                          tempVolume = value;
                        });
                      },
                      colors,
                    ),
                    _filterGroup(
                      "Liquidity",
                      ["All", "> \$10K", "> \$50K", "> \$250K", "> \$1M"],
                      tempLiquidity,
                      (value) {
                        setModalState(() {
                          tempLiquidity = value;
                        });
                      },
                      colors,
                    ),
                    _filterGroup(
                      "24H Change",
                      ["All", "> +20%", "> +10%", "0% – +10%", "< 0%"],
                      tempChange,
                      (value) {
                        setModalState(() {
                          tempChange = value;
                        });
                      },
                      colors,
                    ),
                    _filterGroup(
                      l10n.chartsPairAge,
                      ["All", "< 1H", "< 6H", "< 24H", "< 7D"],
                      tempAge,
                      (value) {
                        setModalState(() {
                          tempAge = value;
                        });
                      },
                      colors,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempMC = "All";
                                tempVolume = "All";
                                tempLiquidity = "All";
                                tempChange = "All";
                                tempAge = "All";
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.secondaryText,
                              side: BorderSide(color: colors.border),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              l10n.chartsReset,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                dexMarketCap = tempMC;
                                dexVolume = tempVolume;
                                dexLiquidity = tempLiquidity;
                                dexChange = tempChange;
                                dexAge = tempAge;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: neonBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              l10n.chartsApplyFilters,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterGroup(
    String title,
    List<String> options,
    String selected,
    ValueChanged<String> onChanged,
    AvexaColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _categoryLabel(title),
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: options.map((option) {
              final active = selected == option;
              return GestureDetector(
                onTap: () => onChanged(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? neonBlue.withOpacity(.12)
                        : colors.background,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: active ? neonBlue : colors.border,
                    ),
                  ),
                  child: Text(
                    option == "All" ? l10n.chartsAll : option,
                    style: GoogleFonts.poppins(
                      color: active ? neonBlue : colors.secondaryText,
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // DEX CARD
  // ================================================================
  Widget _dexCard(Map<String, dynamic> pair, AvexaColors colors) {
    final change = _toDouble(pair["priceChange"]?["h24"]);
    final changeColor = change >= 0 ? neonGreen : neonRed;
    final symbol =
        pair["baseToken"]?["symbol"]?.toString().toUpperCase() ?? "-";
    final name = pair["baseToken"]?["name"]?.toString() ?? symbol;
    final tokenAddress =
        pair["baseToken"]?["address"]?.toString() ?? "";

    final favoriteKey = tokenAddress.isEmpty
        ? null
        : ChartFavoritesService.dexKey(
            pair["chainId"]?.toString() ?? "",
            tokenAddress,
          );

    final isFavorite =
        favoriteKey != null && favorites.contains(favoriteKey);
    final image = pair["info"]?["imageUrl"]?.toString();
    final buys = _toDouble(pair["txns"]?["h24"]?["buys"]);
    final sells = _toDouble(pair["txns"]?["h24"]?["sells"]);
    final totalTrades = buys + sells;
    final buyRatio = totalTrades > 0
        ? (buys / totalTrades).clamp(0.0, 1.0)
        : 0.5;
    final liquidity = _toDouble(pair["liquidity"]?["usd"]);
    final volume = _toDouble(pair["volume"]?["h24"]);
    final marketCap = _toDouble(pair["marketCap"]);
    final pairAddress = pair["pairAddress"]?.toString() ?? "-";
    return GestureDetector(
      onTap: () async {
        await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => CoinDetailsScreen(
              coinId: '',
              pair: symbol,
              price: '\$${pair["priceUsd"] ?? "-"}',
              change:
                  '${change >= 0 ? "+" : ""}${change.toStringAsFixed(2)}%',
              color: changeColor,
              dexPair: pair,
              isFavorite: isFavorite,
            ),
          ),
        );

        if (!mounted) return;

        await _loadFavorites();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: neonBlue.withOpacity(.045),
              blurRadius: 22,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: neonBlue.withOpacity(.25)),
                    boxShadow: [
                      BoxShadow(
                        color: neonBlue.withOpacity(.08),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: _coinImage(image, 44, colors),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              symbol,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: colors.primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          _smallBadge(_chainName(pair["chainId"])),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: colors.mutedText,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        "DEX • ${pair["dexId"] ?? "-"}",
                        style: GoogleFonts.poppins(
                          color: colors.mutedText,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (favoriteKey != null)
                  IconButton(
                    tooltip: isFavorite
                        ? "Remove from Favorites"
                        : "Add to Favorites",
                    onPressed: () async {
                      final updatedFavorites = Set<String>.from(favorites);

                      if (updatedFavorites.contains(favoriteKey)) {
                        updatedFavorites.remove(favoriteKey);
                      } else {
                        updatedFavorites.add(favoriteKey);
                      }

                      setState(() {
                        favorites = updatedFavorites;
                      });

                      await ChartFavoritesService.saveFavorites(
                        updatedFavorites,
                      );
                    },
                    icon: Icon(
                      isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 23,
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${pair["priceUsd"] ?? "-"}",
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: changeColor.withOpacity(.10),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: changeColor.withOpacity(.20)),
                      ),
                      child: Text(
                        "${change >= 0 ? "+" : ""}${change.toStringAsFixed(2)}%",
                        style: GoogleFonts.poppins(
                          color: changeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _dexMetric(
                      l10n.chartsMarketCapUpper,
                      _formatMoney(marketCap),
                      colors,
                    ),
                  ),
                  Container(width: 1, height: 30, color: colors.border),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: _dexMetric(
                        l10n.chartsLiquidityUpper,
                        _formatMoney(liquidity),
                        colors,
                      ),
                    ),
                  ),
                  Container(width: 1, height: 30, color: colors.border),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: _dexMetric(
                        l10n.chartsVolume24Upper,
                        _formatMoney(volume),
                        colors,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.swap_vert_rounded, color: neonBlue, size: 18),
                const SizedBox(width: 7),
                Text(
                  l10n.chartsFlow24Upper,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.chartsBuysCount(buys.toInt()),
                  style: GoogleFonts.poppins(
                    color: neonGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.chartsSellsCount(sells.toInt()),
                  style: GoogleFonts.poppins(
                    color: neonRed,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 7,
                child: Row(
                  children: [
                    Expanded(
                      flex: (buyRatio * 1000).round().clamp(1, 999),
                      child: Container(color: neonGreen),
                    ),
                    Expanded(
                      flex: ((1 - buyRatio) * 1000).round().clamp(1, 999),
                      child: Container(color: neonRed),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.elevatedCard,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: colors.mutedText,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _pairAge(pair["pairCreatedAt"]),
                        style: GoogleFonts.poppins(
                          color: colors.mutedText,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  pairAddress.length > 10
                      ? "${pairAddress.substring(0, 5)}...${pairAddress.substring(pairAddress.length - 5)}"
                      : pairAddress,
                  style: GoogleFonts.poppins(
                    color: colors.mutedText,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colors.mutedText,
                  size: 11,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dexMetric(String title, String value, AvexaColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _categoryLabel(title),
          style: GoogleFonts.poppins(
            color: colors.mutedText,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _smallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: neonBlue.withOpacity(.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: neonBlue.withOpacity(.16)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: neonBlue,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _emptyDexState(AvexaColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: _cardDecoration(colors),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: colors.mutedText, size: 42),
          const SizedBox(height: 12),
          Text(
            l10n.chartsNoDexPairs,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.chartsWidenFilters,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // HELPERS
  // ================================================================
  Widget _coinImage(dynamic url, double size, AvexaColors colors) {
    if (url == null || url.toString().isEmpty) {
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
        url.toString(),
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
          child: const Icon(Icons.token_rounded, color: neonBlue, size: 20),
        ),
      ),
    );
  }

  Future<void> _openCoin(dynamic coin) async {
    final change = (coin["price_change_percentage_24h"] ?? 0).toDouble();
    final symbol = (coin["symbol"] as String).toUpperCase();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoinDetailsScreen(
          coinId: coin["id"],
          pair: symbol,
          price: "\$${coin["current_price"]}",
          change: "${change >= 0 ? "+" : ""}${change.toStringAsFixed(2)}%",
          color: change >= 0 ? neonGreen : neonRed,
          isFavorite: favorites.contains(
            ChartFavoritesService.coinKey(symbol),
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (result is bool) {
      final favoriteKey = ChartFavoritesService.coinKey(symbol);
      final updatedFavorites = Set<String>.from(favorites);

      if (result) {
        updatedFavorites.add(favoriteKey);
      } else {
        updatedFavorites.remove(favoriteKey);
      }

      setState(() {
        favorites = updatedFavorites;
      });

      await ChartFavoritesService.saveFavorites(updatedFavorites);
    }
  }

  BoxDecoration _cardDecoration(AvexaColors colors) {
    return BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: colors.border),
      boxShadow: [BoxShadow(color: neonBlue.withOpacity(.04), blurRadius: 20)],
    );
  }

  String _chainName(dynamic chain) {
    switch (chain?.toString()) {
      case "solana":
        return "Solana";
      case "ethereum":
        return "Ethereum";
      case "base":
        return "Base";
      case "arbitrum":
        return "Arbitrum";
      case "bsc":
        return "BSC";
      default:
        return chain?.toString() ?? "-";
    }
  }

  String _pairAge(dynamic timestamp) {
    if (timestamp == null) return "-";
    final created = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(timestamp.toString()) ?? 0,
    );
    final difference = DateTime.now().difference(created);
    if (difference.inDays > 0) {
      return "${difference.inDays}d old";
    }
    if (difference.inHours > 0) {
      return "${difference.inHours}h old";
    }
    return "${difference.inMinutes}m old";
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  String _formatMoney(dynamic value) {
    final number = _toDouble(value);
    if (number >= 1000000000) {
      return "\$${(number / 1000000000).toStringAsFixed(1)}B";
    }
    if (number >= 1000000) {
      return "\$${(number / 1000000).toStringAsFixed(1)}M";
    }
    if (number >= 1000) {
      return "\$${(number / 1000).toStringAsFixed(1)}K";
    }
    return "\$${number.toStringAsFixed(0)}";
  }

  String _categoryLabel(String value) {
    switch (value) {
      case "Favorites":
        return l10n.chartsFavorites;
      case "DEX":
        return "DEX";
      case "Trending":
        return l10n.chartsTrending;
      case "Spot":
        return l10n.chartsSpot;
      case "Futures":
        return l10n.chartsFutures;
      default:
        return value;
    }
  }

  String _sortLabel(String value) {
    switch (value) {
      case "Market Cap":
        return l10n.chartsMarketCap;
      case "Volume":
        return l10n.chartsVolume;
      case "24H Change":
        return l10n.chartsChange24;
      case "Rank":
        return l10n.chartsRank;
      case "Liquidity":
        return l10n.chartsLiquidity;
      default:
        return value;
    }
  }

  String _moverLabel(String value) {
    switch (value) {
      case "Gainers":
        return l10n.chartsGainers;
      case "Losers":
        return l10n.chartsLosers;
      default:
        return value;
    }
  }
}
