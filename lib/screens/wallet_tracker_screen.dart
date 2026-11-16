
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../services/wallet_tracker_service.dart';
import 'wallet_details_screen.dart';

class WalletTrackerScreen extends StatefulWidget {
  const WalletTrackerScreen({super.key});

  @override
  State<WalletTrackerScreen> createState() =>
      _WalletTrackerScreenState();
}

class _WalletTrackerScreenState extends State<WalletTrackerScreen> {
  bool isLoading = true;
  bool isSyncing = false;
  String? errorMessage;

  List<Map<String, dynamic>> wallets = [];
  List<Map<String, dynamic>> transactions = [];

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await WalletTrackerService.getWalletData();

      if (!mounted) return;

      setState(() {
        wallets = List<Map<String, dynamic>>.from(
          result['wallets'] ?? [],
        );
        transactions = List<Map<String, dynamic>>.from(
          result['transactions'] ?? [],
        );
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _syncWallets() async {
    if (isSyncing) return;

    setState(() => isSyncing = true);

    try {
      final result = await WalletTrackerService.syncWallets();

      if (!mounted) return;

      await _loadWalletData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF172338),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          content: Text(
            l10n.walletTrackerSyncComplete(
              result['wallets'] ?? 0,
              result['checked'] ?? 0,
              result['swapsFound'] ?? 0,
              result['inserted'] ?? 0,
            ),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            l10n.walletTrackerSyncError(e.toString()),
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSyncing = false);
      }
    }
  }

  Future<void> _showAddWalletDialog() async {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final localizations = l10n;

    final nameController = TextEditingController();
    final addressController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: colors.border),
          ),
          title: Text(
            localizations.walletTrackerAddWallet,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(
                context: dialogContext,
                controller: nameController,
                label: localizations.walletTrackerWalletName,
                hint: localizations.walletTrackerWalletNameHint,
              ),
              const SizedBox(height: 14),
              _dialogField(
                context: dialogContext,
                controller: addressController,
                label: localizations.walletTrackerWalletAddress,
                hint: localizations.walletTrackerAddressHint,
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                localizations.walletTrackerCancel,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: neonBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final address = addressController.text.trim();

                if (name.isEmpty || address.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        localizations.walletTrackerEnterWalletDetails,
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await WalletTrackerService.addWallet(
                    name: name,
                    address: address,
                    network: 'Solana',
                  );

                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext, true);
                } catch (e) {
                  if (!dialogContext.mounted) return;

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        localizations.walletTrackerAddError,
                      ),
                    ),
                  );
                }
              },
              child: Text(
                localizations.walletTrackerAddWallet,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    addressController.dispose();

    if (result == true) {
      await _loadWalletData();
    }
  }

  Future<void> _openWalletDetails(
    Map<String, dynamic> wallet,
  ) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WalletDetailsScreen(
          wallet: wallet,
          transactions: transactions,
        ),
      ),
    );

    if (changed == true) {
      await _loadWalletData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final localizations = l10n;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: neonBlue,
          onRefresh: _loadWalletData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: _buildHeader(colors),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _buildHero(colors, localizations),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(
                    children: [
                      Text(
                        localizations.walletTrackerYourWallets,
                        style: GoogleFonts.poppins(
                          color: colors.primaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .7,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: neonBlue.withOpacity(.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: neonBlue.withOpacity(.20),
                          ),
                        ),
                        child: Text(
                          '${wallets.length} ${localizations.walletTrackerTracked}',
                          style: GoogleFonts.poppins(
                            color: neonBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildWalletList(colors),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
                  child: _buildAddButton(localizations),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AvexaColors colors) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 42,
              minHeight: 42,
            ),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colors.primaryText,
              size: 19,
            ),
          ),
          const Spacer(),
          Text(
            l10n.walletTrackerTitle,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _buildHero(
    AvexaColors colors,
    AppLocalizations localizations,
  ) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Image.asset(
            'assets/images/wallet_tracker_alien.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                color: neonBlue.withOpacity(.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: neonBlue.withOpacity(.18),
                ),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: neonBlue,
                size: 58,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          localizations.walletTrackerHeroTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          localizations.walletTrackerHeroDescription,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: colors.mutedText,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletList(AvexaColors colors) {
    if (isLoading) {
      return _panel(
        colors,
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: CircularProgressIndicator(color: neonBlue),
        ),
      );
    }

    if (errorMessage != null) {
      return _panel(
        colors,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: neonRed,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.walletTrackerLoadError,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.walletTrackerRetry,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _loadWalletData,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.walletTrackerRetry),
            ),
          ],
        ),
      );
    }

    if (wallets.isEmpty) {
      return _panel(
        colors,
        padding: const EdgeInsets.all(26),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: colors.mutedText,
              size: 38,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.walletTrackerEmptyTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: colors.primaryText,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.walletTrackerEmptyDescription,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return _panel(
      colors,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (int i = 0; i < wallets.length; i++) ...[
            _walletRow(wallets[i], colors),
            if (i != wallets.length - 1)
              Divider(
                height: 1,
                indent: 18,
                endIndent: 18,
                color: colors.border,
              ),
          ],
        ],
      ),
    );
  }

  Widget _panel(
    AvexaColors colors, {
    required Widget child,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: child,
    );
  }

  Widget _walletRow(
    Map<String, dynamic> wallet,
    AvexaColors colors,
  ) {
    final name =
        wallet['name']?.toString() ?? l10n.walletTrackerDefaultName;
    final address = wallet['address']?.toString() ?? '';
    final network = wallet['network']?.toString() ?? 'Solana';
    final isActive = wallet['is_active'] != false;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openWalletDetails(wallet),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: neonBlue.withOpacity(.10),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: neonBlue.withOpacity(.18),
                ),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: neonBlue,
                size: 23,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _shortAddress(address),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: colors.mutedText,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? neonGreen : colors.mutedText,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isActive
                            ? l10n.walletTrackerActive
                            : l10n.walletTrackerInactive,
                        style: GoogleFonts.poppins(
                          color: isActive ? neonGreen : colors.mutedText,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .4,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        network,
                        style: GoogleFonts.poppins(
                          color: colors.secondaryText,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.mutedText,
              size: 23,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(AppLocalizations localizations) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _showAddWalletDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: neonBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          localizations.walletTrackerAddButton,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: .6,
          ),
        ),
      ),
    );
  }

  Widget _dialogField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    final colors = Theme.of(context).extension<AvexaColors>()!;

    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(
        color: colors.primaryText,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(color: colors.secondaryText),
        hintStyle: GoogleFonts.poppins(
          color: colors.mutedText,
          fontSize: 12,
        ),
        filled: true,
        fillColor: colors.elevatedCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: neonBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  String _shortAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }
}
