
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../services/connection_service.dart';
import '../widgets/app_page_header.dart';
import 'connect_portfolio_screen.dart';
import 'connected_accounts_screen.dart';
import 'profile_screen.dart';
import '../services/wallet_service.dart';
import '../models/portfolio_asset.dart';
import '../services/subscription_state.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with SingleTickerProviderStateMixin {
  final connectionService = ConnectionService.instance;
  final Map<String, double> _walletValues = {};

  final walletService = WalletService.instance;

  final GlobalKey<_ProfileBannerState> _profileBannerKey =
      GlobalKey<_ProfileBannerState>();

  bool _loadingPortfolio = true;
  String? _portfolioError;

  late final AnimationController _badgeController;
  late final Animation<double> _badgeVertical;
  late final Animation<double> _badgeRotation;
  late final Animation<double> _badgeScale;

  bool _loadingConnections = true;

  int _selectedWalletIndex = 0;

  @override
  void initState() {
    super.initState();

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _badgeVertical = Tween<double>(
      begin: -3.0,
      end: 3.0,
    ).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: Curves.easeInOut,
      ),
    );

    _badgeRotation = Tween<double>(
      begin: -0.006,
      end: 0.006,
    ).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: Curves.easeInOut,
      ),
    );

    _badgeScale = Tween<double>(
      begin: 0.997,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: Curves.easeInOut,
      ),
    );

    _loadConnections();
  }

  Future<void> _loadConnections() async {
    try {
      await connectionService.load();
      await _loadPortfolio();
    } catch (e) {
      if (mounted) {
        setState(() {
          _portfolioError =
              AppLocalizations.of(context)!.portfolioLoadError;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loadingConnections = false);
      }
    }
  }

  Future<void> _loadPortfolio() async {
    if (mounted) {
      setState(() {
        _loadingPortfolio = true;
        _portfolioError = null;
      });
    }

    try {
      final wallets = connectionService.walletAccounts
          .where((wallet) =>
              wallet.network?.toLowerCase() == 'solana' &&
              wallet.walletAddress != null &&
              wallet.walletAddress!.isNotEmpty)
          .toList();

      final Map<String, double> newValues = {};

      for (final wallet in wallets) {
        final address = wallet.walletAddress!;

        // Pobieramy aktywa z danego portfela.
        final assets = await walletService.getSolanaPortfolio(address);

        // Sumujemy ich wartości USD.
        final walletTotal = assets.fold<double>(
          0.0,
          (sum, asset) => sum + asset.valueUsd,
        );

        newValues[address] = walletTotal;
      }

      if (!mounted) return;

      setState(() {
        _walletValues
          ..clear()
          ..addAll(newValues);

        _selectedWalletIndex = wallets.isEmpty
            ? 0
            : _selectedWalletIndex.clamp(0, wallets.length - 1).toInt();
      });
    } catch (e, stackTrace) {
      debugPrint('========== PORTFOLIO ERROR ==========');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('=====================================');

      if (mounted) {
        setState(() {
          _portfolioError =
              AppLocalizations.of(context)!.portfolioSyncError;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingPortfolio = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  Future<void> _openConnect() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConnectPortfolioScreen(),
      ),
    );

    await connectionService.load();
    await _loadPortfolio();

    if (mounted) setState(() {});
  }

  Future<void> _openManageConnections() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConnectedAccountsScreen(),
      ),
    );

    await connectionService.load();
    await _loadPortfolio();

    if (mounted) setState(() {});
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final wallets = connectionService.walletAccounts;
    final totalValue = _walletValues.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    final portfolioWallets = wallets
        .where((wallet) =>
            wallet.network?.toLowerCase() == 'solana' &&
            wallet.walletAddress != null &&
            wallet.walletAddress!.isNotEmpty)
        .toList();

    final hasWallets = wallets.isNotEmpty;

    final selectedIndex = portfolioWallets.isEmpty
        ? 0
        : _selectedWalletIndex
            .clamp(0, portfolioWallets.length - 1)
            .toInt();

    final networks = wallets
        .map((wallet) => wallet.network?.toLowerCase())
        .where((network) => network != null && network.isNotEmpty)
        .toSet();

    final chainCount = networks.length;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(
                title: l10n.portfolioHeaderProfile,
              ),

              const SizedBox(height: 12),

              AnimatedBuilder(
                animation: _badgeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      -8 + _badgeVertical.value,
                    ),
                    child: Transform.rotate(
                      angle: _badgeRotation.value,
                      child: Transform.scale(
                        scale: _badgeScale.value,
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );

                            if (!mounted) return;

                            await _profileBannerKey.currentState
                                ?.reloadProfile();

                            if (mounted) setState(() {});
                          },
                          behavior: HitTestBehavior.opaque,
                          child: _ProfileBanner(
                            key: _profileBannerKey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 2),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 15,
                      color: colors.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.portfolioTapToViewProfile,
                      style: GoogleFonts.poppins(
                        color: colors.secondaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              _buildWalletCarousel(
                colors: colors,
                l10n: l10n,
                wallets: portfolioWallets,
                walletValues: _walletValues,
                totalValue: totalValue,
              ),

              const SizedBox(height: 30),

              _buildConnectionSection(
                colors: colors,
                l10n: l10n,
                hasWallets: hasWallets,
                walletCount: wallets.length,
              ),

              const SizedBox(height: 30),

              _buildHistoryNotice(colors, l10n),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PORTFOLIO HERO
  // ============================================================

  Widget _buildWalletCarousel({
    required AvexaColors colors,
    required AppLocalizations l10n,
    required List<dynamic> wallets,
    required Map<String, double> walletValues,
    required double totalValue,
  }) {
    final pageCount = wallets.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.portfolioValue,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: neonGreen.withOpacity(.09),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: neonGreen.withOpacity(.20),
                ),
              ),
              child: Text(
                l10n.portfolioWalletCount(pageCount, 3),
                style: GoogleFonts.poppins(
                  color: neonGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (pageCount == 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colors.border,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: neonBlue,
                  size: 36,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.portfolioNoWallets,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.portfolioConnectSolanaWallet,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadingConnections ? null : _openConnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.portfolioConnectWallet),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 270,
            child: PageView.builder(
              itemCount: pageCount,
              onPageChanged: (index) {
                setState(() {
                  _selectedWalletIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                final address = wallet.walletAddress!.toString();
                final walletValue = walletValues[address] ?? 0.0;

                final walletName = wallet.customName?.trim().isNotEmpty == true
                    ? wallet.customName!.trim()
                    : l10n.portfolioValue;

                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      16,
                    ),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: neonBlue.withOpacity(.22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: neonBlue.withOpacity(.035),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                walletName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: colors.primaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _loadingPortfolio
                                  ? null
                                  : _loadPortfolio,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: neonBlue,
                              ),
                              tooltip: l10n.portfolioRefreshWallet,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          l10n.portfolioWalletPosition(
                            index + 1,
                            pageCount,
                          ),
                          style: GoogleFonts.poppins(
                            color: colors.secondaryText,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 9),

                        Text(
                          _loadingPortfolio
                              ? l10n.portfolioLoading
                              : _portfolioError != null
                                  ? l10n.portfolioUnavailable
                                  : _formatCurrency(walletValue),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: colors.primaryText,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          l10n.portfolioWalletBalance,
                          style: GoogleFonts.poppins(
                            color: colors.secondaryText,
                            fontSize: 12,
                          ),
                        ),

                        const Spacer(),

                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              pageCount,
                              (dotIndex) {
                                final active = index == dotIndex;

                                return AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: 220,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  width: active ? 34 : 27,
                                  height: 27,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? neonBlue.withOpacity(.13)
                                        : colors.border.withOpacity(.55),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: active ? 10 : 9,
                                      height: active ? 10 : 9,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: active
                                            ? neonBlue
                                            : colors.secondaryText,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 9),

                        Center(
                          child: Text(
                            l10n.portfolioSwipeWallets,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: colors.secondaryText,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 13),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: neonBlue.withOpacity(.055),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: neonBlue.withOpacity(.14),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: neonBlue,
                size: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.portfolioCombinedValue,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                _loadingPortfolio
                    ? '...'
                    : _portfolioError != null
                        ? l10n.portfolioUnavailable
                        : _formatCurrency(totalValue),
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        if (_portfolioError != null) ...[
          const SizedBox(height: 10),
          Text(
            _portfolioError!,
            style: GoogleFonts.poppins(
              color: Colors.orangeAccent,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // CONNECTIONS
  // ============================================================

  Widget _buildConnectionSection({
    required AvexaColors colors,
    required AppLocalizations l10n,
    required bool hasWallets,
    required int walletCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.portfolioConnectedWallets,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (hasWallets)
              Text(
                l10n.portfolioConnectedCount(walletCount),
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 11,
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: neonBlue.withOpacity(.10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      hasWallets
                          ? Icons.account_balance_wallet_rounded
                          : Icons.link_rounded,
                      color: neonBlue,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasWallets
                              ? l10n.portfolioWalletAddressesConnected
                              : l10n.portfolioNoWallets,
                          style: GoogleFonts.poppins(
                            color: colors.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasWallets
                              ? l10n.portfolioManageAddressesNetworks
                              : l10n.portfolioConnectPublicAddress,
                          style: GoogleFonts.poppins(
                            color: colors.secondaryText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _loadingConnections
                      ? null
                      : _openManageConnections,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.settings_outlined, size: 19),
                  label: Text(
                    l10n.portfolioManageConnections,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: _loadingConnections || walletCount >= 3
                      ? null
                      : _openConnect,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: neonBlue,
                    side: BorderSide(
                      color: neonBlue.withOpacity(.45),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 19),
                  label: Text(
                    walletCount >= 3
                        ? l10n.portfolioMaxWalletsReached
                        : l10n.portfolioAddAnotherWallet,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PORTFOLIO OVERVIEW
  // ============================================================

  Widget _buildOverview({
    required AvexaColors colors,
    required AppLocalizations l10n,
    required List<PortfolioAsset> assets,
    required int chainCount,
    required bool hasWallets,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.portfolioOverview,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _statCard(
                title: l10n.portfolioAssets,
                value: assets.length.toString(),
                icon: Icons.token_rounded,
                colors: colors,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _statCard(
                title: l10n.portfolioChains,
                value: chainCount.toString(),
                icon: Icons.hub_rounded,
                colors: colors,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _statCard(
                title: l10n.portfolioNfts,
                value: '—',
                icon: Icons.image_outlined,
                colors: colors,
              ),
            ),
          ],
        ),

        if (!hasWallets) ...[
          const SizedBox(height: 14),
          Text(
            l10n.portfolioConnectToBuild,
            style: GoogleFonts.poppins(
              color: colors.mutedText,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required AvexaColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: neonBlue,
            size: 19,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: colors.mutedText,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ASSETS
  // ============================================================

  Widget _buildAssetsSection({
    required AvexaColors colors,
    required AppLocalizations l10n,
    required List<PortfolioAsset> assets,
    required bool hasWallets,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.portfolioAssets,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 14),

        if (assets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 28,
            ),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.border,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: neonBlue.withOpacity(.09),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.layers_outlined,
                    color: neonBlue,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  l10n.portfolioNoAssetsSynced,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  hasWallets
                      ? l10n.portfolioAssetsSyncPending
                      : l10n.portfolioConnectToBuild,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          )
        else
          ...assets.map(
            (asset) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.border,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: neonBlue.withOpacity(.10),
                    child: Text(
                      asset.symbol,
                      style: const TextStyle(
                        color: neonBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: GoogleFonts.poppins(
                            color: colors.primaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${asset.amount} ${asset.symbol}',
                          style: GoogleFonts.poppins(
                            color: colors.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    _formatCurrency(asset.valueUsd),
                    style: GoogleFonts.poppins(
                      color: neonGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // HISTORY NOTICE
  // ============================================================

  Widget _buildHistoryNotice(
    AvexaColors colors,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: neonBlue,
              size: 20,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.portfolioAnalytics,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  l10n.portfolioAnalyticsDescription,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// AVEXA PROFILE BANNER - DYNAMIC PREMIUM DESIGN
// ==========================================================================

class _ProfileBanner extends StatefulWidget {
  const _ProfileBanner({super.key});

  @override
  State<_ProfileBanner> createState() => _ProfileBannerState();
}

class _ProfileBannerState extends State<_ProfileBanner> {
  String _username = 'User';
  String _plan = 'Free';
  String? _avatarUrl;

  int _memberSince = DateTime.now().year;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    SubscriptionState.instance.addListener(_onSubscriptionChanged);

    _loadProfile();
  }

  @override
  void dispose() {
    SubscriptionState.instance.removeListener(_onSubscriptionChanged);
    super.dispose();
  }

  void _onSubscriptionChanged() {
    if (!mounted) return;

    final subscription = SubscriptionState.instance;

    debugPrint('PORTFOLIO BANNER LISTENER');
    debugPrint('PORTFOLIO CENTRAL IS PRO: ${subscription.isPro}');

    setState(() {
      _plan = subscription.isPro ? 'Pro' : 'Free';
    });
  }

  Future<void> reloadProfile() async {
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() => _loading = true);
    }

    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() => _loading = false);
        }
        return;
      }

      final profile = await client
          .from('profiles')
          .select('username, avatar_url, plan')
          .eq('id', user.id)
          .maybeSingle();

      final username = profile?['username']?.toString().trim();
      final avatar = profile?['avatar_url']?.toString().trim();

      final email = user.email?.trim();

      final emailName = email != null && email.contains('@')
          ? email.split('@').first
          : null;

      final createdAt = DateTime.tryParse(user.createdAt);

      if (!mounted) return;

      setState(() {
        _username = username != null && username.isNotEmpty
            ? username
            : (emailName != null && emailName.isNotEmpty
                ? emailName
                : AppLocalizations.of(context)!.portfolioDefaultUser);

        _avatarUrl = avatar != null && avatar.isNotEmpty
            ? avatar
            : null;

        _plan = SubscriptionState.instance.isPro ? 'Pro' : 'Free';

        _memberSince = createdAt?.year ?? DateTime.now().year;

        _loading = false;
      });
    } catch (e) {
      debugPrint('PORTFOLIO PROFILE BANNER ERROR: $e');

      final user = Supabase.instance.client.auth.currentUser;

      if (!mounted) return;

      setState(() {
        final email = user?.email?.trim();

        _username = email != null && email.contains('@')
            ? email.split('@').first
            : AppLocalizations.of(context)!.portfolioDefaultUser;

        _memberSince =
            DateTime.tryParse(user?.createdAt ?? '')?.year ??
                DateTime.now().year;

        _loading = false;
      });
    }
  }

  bool get _isPro => _plan.toLowerCase() == 'pro';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = (width * 0.365).clamp(118.0, 142.0);
        final avatarSize = height * 0.61;

        return Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.elevatedCard,
                colors.card,
                Color.lerp(
                  colors.card,
                  neonBlue.withOpacity(.13),
                  0.35,
                )!,
              ],
            ),
            border: Border.all(
              color: neonBlue.withOpacity(.32),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: neonBlue.withOpacity(.13),
                blurRadius: 25,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(.12),
                blurRadius: 12,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Subtle decorative glow
                Positioned(
                  right: -35,
                  top: -65,
                  child: IgnorePointer(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            neonBlue.withOpacity(.17),
                            neonBlue.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 15,
                  bottom: -55,
                  child: IgnorePointer(
                    child: Container(
                      width: 125,
                      height: 125,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            neonBlue.withOpacity(.10),
                            neonBlue.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // User avatar
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              neonBlue,
                              neonBlue.withOpacity(.25),
                              blueDark,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: neonBlue.withOpacity(.30),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _buildAvatar(),
                        ),
                      ),

                      const SizedBox(width: 15),

                      // User information
                      Expanded(
                        child: _loading
                            ? const Center(
                                child: SizedBox(
                                  width: 19,
                                  height: 19,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: neonBlue,
                                  ),
                                ),
                              )
                            : Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Username
                                  Text(
                                    _username,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: colors.primaryText,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: .1,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  // Subscription and active status
                                  Wrap(
                                    spacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              neonBlue,
                                              blueDark,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          boxShadow: [
                                            BoxShadow(
                                              color: neonBlue
                                                  .withOpacity(.17),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          _isPro
                                              ? l10n.portfolioProPlan
                                              : l10n.portfolioFreePlan,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: .35,
                                          ),
                                        ),
                                      ),

                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration:
                                                const BoxDecoration(
                                              color: neonGreen,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: neonGreen,
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            l10n.portfolioActive,
                                            style: GoogleFonts.poppins(
                                              color: colors.secondaryText,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 7),

                                  // Notifications
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.notifications_none_rounded,
                                        color: colors.secondaryText,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          l10n.portfolioNotificationsEnabled,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            color: colors.secondaryText,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 3),

                                  // Membership date
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        color: colors.secondaryText,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          l10n.portfolioMemberSince(
                                            _memberSince,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            color: colors.secondaryText,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),

                // Fine top highlight
                Positioned(
                  top: 0,
                  left: 30,
                  right: 30,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          neonBlue.withOpacity(.65),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    if (_avatarUrl == null || _avatarUrl!.isEmpty) {
      return Container(
        color: cardDark,
        child: const Icon(
          Icons.person_rounded,
          color: neonBlue,
          size: 38,
        ),
      );
    }

    if (_avatarUrl!.startsWith('http')) {
      return Image.network(
        _avatarUrl!,
        key: ValueKey(_avatarUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _fallbackAvatar();
        },
      );
    }

    return Image.asset(
      _avatarUrl!,
      key: ValueKey(_avatarUrl),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _fallbackAvatar();
      },
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: cardDark,
      child: const Icon(
        Icons.person_rounded,
        color: neonBlue,
        size: 38,
      ),
    );
  }
}

// ==========================================================================
// PORTFOLIO CHART PLACEHOLDER
// ==========================================================================

class _FlatPortfolioChartPainter extends CustomPainter {
  final Color lineColor;
  final Color gridColor;

  const _FlatPortfolioChartPainter({
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gridColor.withOpacity(.28);

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = lineColor.withOpacity(.75);

    final centerY = size.height * .52;

    final path = Path()
      ..moveTo(0, centerY)
      ..lineTo(size.width * .12, centerY)
      ..lineTo(size.width * .24, centerY)
      ..lineTo(size.width * .36, centerY)
      ..lineTo(size.width * .48, centerY)
      ..lineTo(size.width * .60, centerY)
      ..lineTo(size.width * .72, centerY)
      ..lineTo(size.width * .84, centerY)
      ..lineTo(size.width, centerY);

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = lineColor;

    canvas.drawCircle(
      Offset(size.width, centerY),
      3.5,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _FlatPortfolioChartPainter oldDelegate,
  ) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
