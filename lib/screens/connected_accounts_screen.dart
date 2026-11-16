
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../models/connected_account.dart';
import '../services/connection_service.dart';
import 'connect_portfolio_screen.dart';

class ConnectedAccountsScreen extends StatefulWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  State<ConnectedAccountsScreen> createState() =>
      _ConnectedAccountsScreenState();
}

class _ConnectedAccountsScreenState
    extends State<ConnectedAccountsScreen> {
  final ConnectionService _connectionService =
      ConnectionService.instance;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool _loading = true;

  List<ConnectedAccount> get _walletAccounts =>
      _connectionService.walletAccounts;

  List<ConnectedAccount> get _legacyAccounts =>
      _connectionService.legacyAccounts;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    await _connectionService.load();

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  Future<void> _openConnectScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConnectPortfolioScreen(),
      ),
    );

    if (!mounted) return;

    await _loadAccounts();
  }

  String _networkName(String network) {
    switch (network.toLowerCase()) {
      case 'solana':
        return 'Solana';
      case 'ethereum':
        return 'Ethereum';
      case 'base':
        return 'Base';
      case 'arbitrum':
        return 'Arbitrum';
      case 'polygon':
        return 'Polygon';
      default:
        return network.toUpperCase();
    }
  }

  Color _networkColor(String network) {
    switch (network.toLowerCase()) {
      case 'solana':
        return const Color(0xFF9945FF);
      case 'ethereum':
        return const Color(0xFF627EEA);
      case 'base':
        return const Color(0xFF0052FF);
      case 'arbitrum':
        return const Color(0xFF28A0F0);
      case 'polygon':
        return const Color(0xFF8247E5);
      default:
        return neonBlue;
    }
  }

  IconData _networkIcon(String network) {
    switch (network.toLowerCase()) {
      case 'solana':
        return Icons.bolt_rounded;
      case 'ethereum':
        return Icons.diamond_outlined;
      case 'base':
        return Icons.layers_outlined;
      case 'arbitrum':
        return Icons.account_tree_outlined;
      case 'polygon':
        return Icons.hexagon_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  String _shortenAddress(String address) {
    if (address.length <= 16) return address;

    return '${address.substring(0, 8)}...'
        '${address.substring(address.length - 6)}';
  }

  Future<void> _copyAddress(String address) async {
    await Clipboard.setData(
      ClipboardData(text: address),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: neonGreen,
        content: Text(
          l10n.connectedAccountsAddressCopied,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _renameWallet(
    ConnectedAccount account,
  ) async {
    final controller = TextEditingController(
      text: account.customName ?? '',
    );

    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.elevatedCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: colors.border),
          ),
          title: Text(
            l10n.connectedAccountsRenameWallet,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: l10n.connectedAccountsWalletNameHint,
              hintStyle: GoogleFonts.poppins(
                color: colors.mutedText,
                fontSize: 12,
              ),
              filled: true,
              fillColor: colors.background,
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
                  width: 1.3,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.connectedAccountsCancel.toUpperCase(),
                style: GoogleFonts.poppins(
                  color: colors.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) return;

                Navigator.pop(dialogContext, name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: neonBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.connectedAccountsSave.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null || newName.trim().isEmpty) return;

    try {
      await _connectionService.renameWallet(
        network: account.network!,
        address: account.walletAddress!,
        customName: newName,
      );

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            l10n.connectedAccountsRenameSuccess,
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(l10n.connectedAccountsRenameError(e.toString()));
    }
  }

  Future<void> _disconnectWallet(
    ConnectedAccount account,
  ) async {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.elevatedCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: colors.border),
          ),
          title: Text(
            l10n.connectedAccountsRemoveWalletTitle,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          content: Text(
            l10n.connectedAccountsRemoveWalletDescription,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 12,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: Text(
                l10n.connectedAccountsCancel.toUpperCase(),
                style: GoogleFonts.poppins(
                  color: colors.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE05252),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.connectedAccountsRemove.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _connectionService.disconnectWallet(
        network: account.network!,
        address: account.walletAddress!,
      );

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            l10n.connectedAccountsRemoveSuccess,
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(l10n.connectedAccountsRemoveError(e.toString()));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFE05252),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMascotIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: neonBlue.withOpacity(.10),
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: Image.asset(
        'assets/images/ax_wallet.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildHeader(AvexaColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildMascotIcon(45),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.connectedAccountsHeader,
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.connectedAccountsSubtitle,
                      style: GoogleFonts.poppins(
                        color: colors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: neonGreen.withOpacity(.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.connectedAccountsConnectedCount(
                    _walletAccounts.length,
                  ).toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: neonGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            l10n.connectedAccountsHeaderDescription,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(
    ConnectedAccount account,
    AvexaColors colors,
  ) {
    final network = account.network ?? '';
    final address = account.walletAddress ?? '';
    final color = _networkColor(network);

    final displayName =
        account.customName?.trim().isNotEmpty == true
            ? account.customName!.trim()
            : '${_networkName(network)} ${l10n.connectedAccountsWallet}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _networkIcon(network),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _networkName(network),
                      style: GoogleFonts.poppins(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz,
                  color: colors.secondaryText,
                ),
                color: colors.elevatedCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  if (value == 'rename') {
                    _renameWallet(account);
                  } else if (value == 'remove') {
                    _disconnectWallet(account);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: colors.secondaryText,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.connectedAccountsRename,
                          style: GoogleFonts.poppins(
                            color: colors.primaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Color(0xFFE05252),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.connectedAccountsRemoveWallet,
                          style: const TextStyle(
                            color: Color(0xFFE05252),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.border.withOpacity(.7),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _shortenAddress(address),
                    style: GoogleFonts.robotoMono(
                      color: colors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _copyAddress(address),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.copy_rounded,
                      color: colors.mutedText,
                      size: 16,
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

  Widget _buildEmptyState(AvexaColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _buildMascotIcon(66),
          const SizedBox(height: 18),
          Text(
            l10n.connectedAccountsEmptyTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.connectedAccountsEmptyDescription,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 11,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 47,
            child: ElevatedButton.icon(
              onPressed: _openConnectScreen,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                l10n.connectedAccountsConnectWallet.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: neonBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyNotice(AvexaColors colors) {
    if (_legacyAccounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: colors.mutedText,
            size: 20,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              l10n.connectedAccountsLegacyNotice(
                _legacyAccounts.length,
              ),
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 10,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice(AvexaColors colors) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: neonBlue.withOpacity(.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: neonBlue.withOpacity(.13),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: neonBlue,
            size: 21,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              l10n.connectedAccountsSecurityNotice,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 10,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.connectedAccountsTitle,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadAccounts,
            icon: Icon(
              Icons.refresh_rounded,
              color: colors.secondaryText,
            ),
            tooltip: l10n.connectedAccountsRefresh,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: neonBlue,
                strokeWidth: 2.5,
              ),
            )
          : RefreshIndicator(
              color: neonBlue,
              onRefresh: _loadAccounts,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  30,
                ),
                children: [
                  _buildHeader(colors),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.connectedAccountsYourWallets.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: colors.secondaryText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      if (_walletAccounts.isNotEmpty)
                        TextButton.icon(
                          onPressed: _openConnectScreen,
                          icon: const Icon(
                            Icons.add,
                            size: 17,
                          ),
                          label: Text(
                            l10n.connectedAccountsAddWallet.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: neonBlue,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (_walletAccounts.isEmpty)
                    _buildEmptyState(colors)
                  else
                    ..._walletAccounts.map(
                      (account) => _buildWalletCard(
                        account,
                        colors,
                      ),
                    ),

                  _buildLegacyNotice(colors),

                  _buildSecurityNotice(colors),
                ],
              ),
            ),
    );
  }
}
