
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/wallet_tracker_service.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';

class WalletDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> wallet;
  final List<Map<String, dynamic>> transactions;

  const WalletDetailsScreen({
    super.key,
    required this.wallet,
    required this.transactions,
  });

  @override
  State<WalletDetailsScreen> createState() => _WalletDetailsScreenState();
}

class _WalletDetailsScreenState extends State<WalletDetailsScreen> {
  late String walletName;
  late List<Map<String, dynamic>> _transactions;

  late bool alertsEnabled;
  late bool buyAlerts;
  late bool sellAlerts;
  late bool largeTransactionAlerts;

  bool isSaving = false;
  bool _isRefreshing = false;
  bool _changed = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();

    walletName = widget.wallet['name']?.toString() ?? 'Wallet';
    _transactions = List<Map<String, dynamic>>.from(widget.transactions);

    alertsEnabled = widget.wallet['alerts_enabled'] != false;
    buyAlerts = widget.wallet['buy_alerts'] != false;
    sellAlerts = widget.wallet['sell_alerts'] != false;
    largeTransactionAlerts =
        widget.wallet['large_transaction_alerts'] != false;
  }

  List<Map<String, dynamic>> get walletTransactions {
    final id = widget.wallet['id']?.toString();

    final rows = _transactions
        .where((t) => t['wallet_id']?.toString() == id)
        .toList();

    rows.sort((a, b) {
      final da = DateTime.tryParse(a['occurred_at']?.toString() ?? '');
      final db = DateTime.tryParse(b['occurred_at']?.toString() ?? '');

      return (db ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(da ?? DateTime.fromMillisecondsSinceEpoch(0));
    });

    return rows;
  }

  Future<void> _refreshTransactions() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      final walletId = widget.wallet['id']?.toString();

      if (walletId == null || walletId.isEmpty) {
        throw Exception('Missing wallet ID');
      }

      final syncResult = await WalletTrackerService.syncWallet(
        walletId: walletId,
      );

      if (syncResult['success'] != true) {
        throw Exception(
          syncResult['error'] ?? 'Wallet synchronization failed',
        );
      }

      final result = await WalletTrackerService.getWalletData();

      if (result['success'] == false) {
        throw Exception(result['error'] ?? 'Refresh failed');
      }

      final raw = result['transactions'];

      final refreshed = raw is List
          ? raw
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .where((t) => t['wallet_id']?.toString() == walletId)
              .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;

      setState(() {
        _transactions = refreshed;
        _changed = true;
      });

      final checked = syncResult['checked'] ?? 0;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.walletDetailsSyncComplete(checked),
            style: GoogleFonts.inter(),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('WALLET DETAILS REFRESH ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.walletDetailsSyncError,
            style: GoogleFonts.inter(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _updateWallet({
    bool? newAlertsEnabled,
    bool? newBuyAlerts,
    bool? newSellAlerts,
    bool? newLargeTransactionAlerts,
  }) async {
    final nextAlerts = newAlertsEnabled ?? alertsEnabled;
    final nextBuy = newBuyAlerts ?? buyAlerts;
    final nextSell = newSellAlerts ?? sellAlerts;
    final nextLarge =
        newLargeTransactionAlerts ?? largeTransactionAlerts;

    final oldAlerts = alertsEnabled;
    final oldBuy = buyAlerts;
    final oldSell = sellAlerts;
    final oldLarge = largeTransactionAlerts;

    setState(() {
      isSaving = true;
      alertsEnabled = nextAlerts;
      buyAlerts = nextBuy;
      sellAlerts = nextSell;
      largeTransactionAlerts = nextLarge;
    });

    try {
      await WalletTrackerService.updateWallet(
        walletId: widget.wallet['id'].toString(),
        alertsEnabled: nextAlerts,
        buyAlerts: nextBuy,
        sellAlerts: nextSell,
        largeTransactionAlerts: nextLarge,
      );

      _changed = true;
    } catch (_) {
      if (!mounted) return;

      setState(() {
        alertsEnabled = oldAlerts;
        buyAlerts = oldBuy;
        sellAlerts = oldSell;
        largeTransactionAlerts = oldLarge;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.walletDetailsUpdateSettingsError,
            style: GoogleFonts.inter(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _renameWallet() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _RenameWalletDialog(),
    );

    if (name == null || name.trim().isEmpty) return;

    try {
      await WalletTrackerService.updateWallet(
        walletId: widget.wallet['id'].toString(),
        name: name.trim(),
      );

      if (!mounted) return;

      setState(() {
        walletName = name.trim();
        _changed = true;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.walletDetailsRenameError,
            style: GoogleFonts.inter(),
          ),
        ),
      );
    }
  }

  Future<void> _deleteWallet() async {
    final c = Theme.of(context).extension<AvexaColors>()!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          l10n.walletDetailsDeleteTitle,
          style: GoogleFonts.inter(
            color: c.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          l10n.walletDetailsDeleteDescription,
          style: GoogleFonts.inter(
            color: c.secondaryText,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: Text(
              l10n.walletDetailsCancel,
              style: GoogleFonts.inter(color: c.secondaryText),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: neonRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(d, true),
            child: Text(
              l10n.walletDetailsDelete,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await WalletTrackerService.deleteWallet(
        walletId: widget.wallet['id'].toString(),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.walletDetailsDeleteError,
            style: GoogleFonts.inter(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AvexaColors>()!;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, _changed),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: c.primaryText,
            size: 19,
          ),
        ),
        title: Text(
          l10n.walletDetailsTitle,
          style: GoogleFonts.inter(
            color: c.primaryText,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _renameWallet,
            tooltip: l10n.walletDetailsRename,
            icon: Icon(
              Icons.edit_outlined,
              color: c.secondaryText,
              size: 21,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
          children: [
            _walletHeader(c),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.walletDetailsLiveActivity,
                    style: GoogleFonts.inter(
                      color: c.primaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  l10n.walletDetailsTransactionCount(
                    walletTransactions.length,
                  ),
                  style: GoogleFonts.inter(
                    color: neonBlue,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(width: 2),
                IconButton(
                  tooltip: l10n.walletDetailsRefreshActivity,
                  onPressed:
                      _isRefreshing ? null : _refreshTransactions,
                  visualDensity: VisualDensity.compact,
                  icon: _isRefreshing
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: neonBlue,
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          color: neonBlue,
                          size: 22,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _transactionContainer(c),
            const SizedBox(height: 28),
            _sectionTitle(
              c,
              l10n.walletDetailsNotifications,
              isSaving
                  ? l10n.walletDetailsSaving
                  : l10n.walletDetailsActive,
            ),
            const SizedBox(height: 12),
            _notificationContainer(c),
            const SizedBox(height: 28),
            _dangerSection(c),
          ],
        ),
      ),
    );
  }

  Widget _walletHeader(AvexaColors c) {
    final address = widget.wallet['address']?.toString() ?? '';
    final network = widget.wallet['network']?.toString() ?? 'Solana';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.12),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: neonBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  walletName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: c.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _shortAddress(address),
                  style: GoogleFonts.inter(
                    color: c.secondaryText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: neonBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      network.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: neonBlue,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .7,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    AvexaColors c,
    String title,
    String trailing,
  ) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: c.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const Spacer(),
        Text(
          trailing,
          style: GoogleFonts.inter(
            color: neonBlue,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: .6,
          ),
        ),
      ],
    );
  }

  Widget _transactionContainer(AvexaColors c) {
    final rows = walletTransactions.take(6).toList();

    if (rows.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: c.mutedText,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              _isRefreshing
                  ? l10n.walletDetailsRefreshing
                  : l10n.walletDetailsNoTransactions,
              style: GoogleFonts.inter(
                color: c.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              l10n.walletDetailsActivityDescription,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: c.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: rows.length == 6 ? 430 : rows.length * 71.0 + 10,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 5),
          itemCount: rows.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
            color: c.border,
          ),
          itemBuilder: (context, i) => _transactionRow(rows[i], c),
        ),
      ),
    );
  }

  Widget _transactionRow(
    Map<String, dynamic> t,
    AvexaColors c,
  ) {
    final rawType = (t['action'] ??
            t['transaction_type'] ??
            t['type'] ??
            'TRANSACTION')
        .toString()
        .toUpperCase();

    final isBuy = rawType == 'BUY';
    final isSell = rawType == 'SELL';

    final type = isBuy
        ? l10n.walletDetailsBuy
        : isSell
            ? l10n.walletDetailsSell
            : l10n.walletDetailsTransaction;

    final token = t['token_symbol']?.toString() ??
        t['symbol']?.toString() ??
        'TOKEN';

    final date = t['occurred_at']?.toString() ?? '';
    final accent = isBuy ? neonBlue : neonRed;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isBuy
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              color: accent,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$type • $token',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: c.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(date),
                  style: GoogleFonts.inter(
                    color: c.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationContainer(AvexaColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          _switchTile(
            c,
            Icons.notifications_active_outlined,
            l10n.walletDetailsWalletAlerts,
            l10n.walletDetailsWalletAlertsDescription,
            alertsEnabled,
            (v) => _updateWallet(newAlertsEnabled: v),
          ),
          _divider(c),
          _switchTile(
            c,
            Icons.shopping_cart_outlined,
            l10n.walletDetailsBuyAlerts,
            l10n.walletDetailsBuyAlertsDescription,
            buyAlerts,
            (v) => _updateWallet(newBuyAlerts: v),
            enabled: alertsEnabled,
          ),
          _divider(c),
          _switchTile(
            c,
            Icons.sell_outlined,
            l10n.walletDetailsSellAlerts,
            l10n.walletDetailsSellAlertsDescription,
            sellAlerts,
            (v) => _updateWallet(newSellAlerts: v),
            enabled: alertsEnabled,
          ),
          _divider(c),
          _switchTile(
            c,
            Icons.warning_amber_rounded,
            l10n.walletDetailsLargeTransactions,
            l10n.walletDetailsLargeTransactionsDescription,
            largeTransactionAlerts,
            (v) => _updateWallet(
              newLargeTransactionAlerts: v,
            ),
            enabled: alertsEnabled,
          ),
        ],
      ),
    );
  }

  Widget _divider(AvexaColors c) {
    return Divider(
      height: 1,
      indent: 18,
      endIndent: 18,
      color: c.border,
    );
  }

  Widget _switchTile(
    AvexaColors c,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 13,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled
                ? (value ? neonBlue : c.secondaryText)
                : c.mutedText,
            size: 21,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: enabled ? c.primaryText : c.mutedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: enabled ? c.secondaryText : c.mutedText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled && !isSaving ? onChanged : null,
            activeColor: Colors.white,
            activeTrackColor: neonBlue,
            inactiveThumbColor: c.mutedText,
            inactiveTrackColor: c.border,
          ),
        ],
      ),
    );
  }

  Widget _dangerSection(AvexaColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: neonRed.withOpacity(.25),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 4,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: neonRed.withOpacity(.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: neonRed,
            size: 21,
          ),
        ),
        title: Text(
          l10n.walletDetailsDeleteWallet,
          style: GoogleFonts.inter(
            color: neonRed,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          l10n.walletDetailsDeleteWalletDescription,
          style: GoogleFonts.inter(
            color: c.secondaryText,
            fontSize: 10,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: c.mutedText,
        ),
        onTap: _deleteWallet,
      ),
    );
  }

  String _shortAddress(String address) {
    if (address.length <= 14) return address;

    return '${address.substring(0, 7)}...${address.substring(address.length - 7)}';
  }

  String _formatDate(String value) {
    if (value.isEmpty) return l10n.walletDetailsUnknownTime;

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    final local = date.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');

    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year}  $h:$m';
  }
}

class _RenameWalletDialog extends StatefulWidget {
  const _RenameWalletDialog();

  @override
  State<_RenameWalletDialog> createState() =>
      _RenameWalletDialogState();
}

class _RenameWalletDialogState extends State<_RenameWalletDialog> {
  late final TextEditingController controller;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AvexaColors>()!;

    return AlertDialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: Text(
        l10n.walletDetailsRenameTitle,
        style: GoogleFonts.inter(
          color: c.primaryText,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: GoogleFonts.inter(color: c.primaryText),
        decoration: InputDecoration(
          hintText: l10n.walletDetailsWalletNameHint,
          hintStyle: GoogleFonts.inter(color: c.mutedText),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: c.border),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: neonBlue),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.walletDetailsCancel,
            style: GoogleFonts.inter(color: c.secondaryText),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: neonBlue,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              Navigator.of(context).pop(name);
            }
          },
          child: Text(
            l10n.walletDetailsSave,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
