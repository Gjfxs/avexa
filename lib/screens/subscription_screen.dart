import '../main.dart' show routeObserver;
import 'package:flutter/material.dart';

import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../services/subscription_service.dart';
import '../services/subscription_purchase_service.dart';
import '../services/subscription_state.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with RouteAware {
  bool yearlySelected = false;

  final SubscriptionPurchaseService _purchaseService =
      SubscriptionPurchaseService.instance;

  bool _storeLoading = true;
  bool _purchaseLoading = false;

  bool _isPro = false;
  bool _isCheckingSubscription = true;

  AvexaColors get colors =>
      Theme.of(context).extension<AvexaColors>()!;

  AppLocalizations get l10n =>
      AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();

    _isPro = SubscriptionState.instance.isPro;
    _isCheckingSubscription = SubscriptionState.instance.isLoading;

    SubscriptionState.instance.addListener(
      _onSubscriptionStateChanged,
    );

    _initializeStore();
    _refreshSubscriptionStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);

    if (route is ModalRoute<void>) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _refreshSubscriptionStatus();
  }

  @override
  void didPush() {
    _refreshSubscriptionStatus();
  }

  @override
  void dispose() {
    SubscriptionState.instance.removeListener(
      _onSubscriptionStateChanged,
    );

    routeObserver.unsubscribe(this);

    super.dispose();
  }

  void _onSubscriptionStateChanged() {
    if (!mounted) return;

    final subscription = SubscriptionState.instance;

    setState(() {
      _isPro = subscription.isPro;
      _isCheckingSubscription = subscription.isLoading;
    });
  }

  Future<void> _refreshSubscriptionStatus() async {
    await SubscriptionState.instance.refresh();
  }

  Future<void> _initializeStore() async {
    await _purchaseService.initialize();

    if (!mounted) return;

    setState(() {
      _storeLoading = false;
    });
  }

  Future<void> _purchaseSelectedPlan() async {
    if (_purchaseLoading) return;

    setState(() {
      _purchaseLoading = true;
    });

    bool started = false;

    try {
      if (yearlySelected) {
        started = await _purchaseService.purchaseYearly();
      } else {
        started = await _purchaseService.purchaseMonthly();
      }
    } finally {
      if (mounted) {
        setState(() {
          _purchaseLoading = false;
        });
      }
    }

    if (!mounted) return;

    if (!started) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.subscriptionUnavailable),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _restorePurchases() async {
    await _purchaseService.restorePurchases();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.subscriptionCheckingPurchases),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String get monthlyPrice =>
      _purchaseService.monthlyProduct?.price ?? '\$9.99';

  String get yearlyPrice =>
      _purchaseService.yearlyProduct?.price ?? '\$79.99';

  // ============================================================
  // LOCALIZED BANNERS
  // ============================================================

  String _bannerPath({
    required bool isPro,
    required String languageCode,
  }) {
    final plan = isPro ? 'pro' : 'free';

    const supported = {
      'en', 'pl', 'de', 'ja', 'ru',
      'ar', 'zh', 'es', 'pt',
    };

    final language = supported.contains(languageCode)
        ? languageCode
        : 'en';

    return 'assets/images/avexa_subscription_${plan}_$language.png';
  }

  Widget _buildSubscriptionBanner({required bool isPro}) {
    final languageCode = Localizations.localeOf(context).languageCode;

    final path = _bannerPath(
      isPro: isPro,
      languageCode: languageCode,
    );

    final fallback = _bannerPath(
      isPro: isPro,
      languageCode: 'en',
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          path,
          key: ValueKey(path),
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            if (path == fallback) {
              return const SizedBox.shrink();
            }

            return Image.asset(
              fallback,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSubscription) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(
          child: CircularProgressIndicator(
            color: neonBlue,
          ),
        ),
      );
    }

    return _isPro
        ? _buildProScreen(context)
        : _buildFreeScreen(context);
  }

  // ============================================================
  // FREE SCREEN
  // ============================================================

  Widget _buildFreeScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),

              const SizedBox(height: 14),

              _buildSubscriptionBanner(isPro: false),

              const SizedBox(height: 28),

              _buildSectionTitle(l10n.subscriptionChoosePlan),

              const SizedBox(height: 12),

              _buildBillingSelector(),

              const SizedBox(height: 14),

              _buildFreePlanCards(),

              const SizedBox(height: 30),

              _buildSectionTitle(l10n.subscriptionFeatures),

              const SizedBox(height: 12),

              _buildFeaturesTable(),

              const SizedBox(height: 22),

              _buildFreeInfoCard(),

              const SizedBox(height: 18),

              _buildPrimaryButton(
                icon: Icons.workspace_premium_rounded,
                title: yearlySelected
                    ? l10n.subscriptionUpgradeYearly(yearlyPrice)
                    : l10n.subscriptionUpgradeMonthly(monthlyPrice),
                onTap: _purchaseSelectedPlan,
              ),

              const SizedBox(height: 10),

              _buildSecondaryButton(
                icon: Icons.credit_card_outlined,
                title: l10n.subscriptionManagePurchases,
                onTap: _purchaseSelectedPlan,
              ),

              const SizedBox(height: 8),

              Center(
                child: TextButton(
                  onPressed: _restorePurchases,
                  child: Text(
                    l10n.subscriptionRestorePurchases,
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRO SCREEN
  // ============================================================

  Widget _buildProScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),

              const SizedBox(height: 14),

              _buildSubscriptionBanner(isPro: true),

              const SizedBox(height: 20),

              _buildActiveSubscriptionCard(),

              const SizedBox(height: 28),

              _buildSectionTitle(l10n.subscriptionYourPlan),

              const SizedBox(height: 12),

              _buildProPlanCards(),

              const SizedBox(height: 30),

              _buildSectionTitle(l10n.subscriptionFeatures),

              const SizedBox(height: 12),

              _buildFeaturesTable(),

              const SizedBox(height: 22),

              _buildProInfoCard(),

              const SizedBox(height: 18),

              _buildSecondaryButton(
                icon: Icons.credit_card_outlined,
                title: l10n.subscriptionManageSubscription,
                onTap: _purchaseSelectedPlan,
              ),

              const SizedBox(height: 10),

              _buildSecondaryButton(
                icon: Icons.swap_horiz_rounded,
                title: l10n.subscriptionChangePlan,
                onTap: () {
                  setState(() {
                    yearlySelected = !yearlySelected;
                  });
                },
              ),

              const SizedBox(height: 10),

              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colors.primaryText,
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          Text(
            l10n.subscriptionTitle,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 27,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: colors.secondaryText,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }

  // ============================================================
  // BILLING SELECTOR
  // ============================================================

  Widget _buildBillingSelector() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBillingOption(
              title: l10n.subscriptionMonthly,
              selected: !yearlySelected,
              onTap: () {
                setState(() {
                  yearlySelected = false;
                });
              },
            ),
          ),
          Expanded(
            child: _buildBillingOption(
              title: l10n.subscriptionYearly,
              selected: yearlySelected,
              badge: l10n.subscriptionSave33,
              onTap: () {
                setState(() {
                  yearlySelected = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? neonBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : colors.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withOpacity(.18)
                        : colors.elevatedCard,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: selected ? Colors.white : neonBlue,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PLAN CARDS
  // ============================================================

  Widget _buildFreePlanCards() {
    return Row(
      children: [
        Expanded(
          child: _buildPlanCard(
            title: 'FREE',
            price: '\$0',
            subtitle: l10n.subscriptionPerMonth,
            selected: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPlanCard(
            title: 'PRO',
            price: yearlySelected ? yearlyPrice : monthlyPrice,
            subtitle: yearlySelected
                ? l10n.subscriptionPerYear
                : l10n.subscriptionPerMonth,
            selected: false,
            badge: yearlySelected ? l10n.subscriptionSave33 : null,
          ),
        ),
      ],
    );
  }

  Widget _buildProPlanCards() {
    return Row(
      children: [
        Expanded(
          child: _buildPlanCard(
            title: l10n.subscriptionProMonthly,
            price: monthlyPrice,
            subtitle: l10n.subscriptionPerMonth,
            selected: !yearlySelected,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPlanCard(
            title: l10n.subscriptionProYearly,
            price: yearlyPrice,
            subtitle: l10n.subscriptionPerYear,
            selected: yearlySelected,
            badge: l10n.subscriptionSave33,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String subtitle,
    required bool selected,
    String? badge,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 142,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? neonBlue.withOpacity(.08) : colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? neonBlue : colors.border,
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: neonBlue.withOpacity(.10),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? neonBlue : colors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: neonBlue,
                  size: 18,
                ),
            ],
          ),
          const Spacer(),
          Text(
            price,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 12,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: neonBlue.withOpacity(.12),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: neonBlue,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // FEATURES TABLE
  // ============================================================

  Widget _buildFeaturesTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _buildFeatureHeader(),
          _buildFeatureRow(
            icon: Icons.bolt_rounded,
            title: l10n.subscriptionDailySignals,
            freeValue: l10n.subscriptionOnePerDay,
            proValue: l10n.subscriptionUnlimited,
          ),
          _buildFeatureRow(
            icon: Icons.auto_awesome,
            title: l10n.subscriptionAiMarketAnalysis,
            freeValue: '—',
            proValue: '✓',
          ),
          _buildFeatureRow(
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.subscriptionWhaleTracking,
            freeValue: '—',
            proValue: '✓',
          ),
          _buildFeatureRow(
            icon: Icons.show_chart_rounded,
            title: l10n.subscriptionAdvancedCharts,
            freeValue: '—',
            proValue: '✓',
          ),
          _buildFeatureRow(
            icon: Icons.trending_up_rounded,
            title: l10n.subscriptionFuturesIntelligence,
            freeValue: '—',
            proValue: '✓',
          ),
          _buildFeatureRow(
            icon: Icons.wallet_outlined,
            title: l10n.subscriptionWalletTracker,
            freeValue: '—',
            proValue: '✓',
          ),
          _buildFeatureRow(
            icon: Icons.newspaper_outlined,
            title: l10n.subscriptionNewsSentiment,
            freeValue: l10n.subscriptionLimited,
            proValue: '✓',
          ),
          _buildFeatureRow(
            icon: Icons.support_agent_outlined,
            title: l10n.subscriptionPrioritySupport,
            freeValue: '—',
            proValue: '✓',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.subscriptionFeatures,
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: .8,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              'FREE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(
            width: 70,
            child: Text(
              'PRO',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: neonBlue,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String freeValue,
    required String proValue,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                top: BorderSide(
                  color: colors.border.withOpacity(.65),
                ),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, color: neonBlue, size: 16),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: _buildFeatureValue(freeValue, isPro: false),
          ),
          SizedBox(
            width: 70,
            child: _buildFeatureValue(proValue, isPro: true),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureValue(
    String value, {
    required bool isPro,
  }) {
    if (value == '✓') {
      return const Center(
        child: Icon(
          Icons.check_circle_rounded,
          color: neonBlue,
          size: 18,
        ),
      );
    }

    if (value == '—') {
      return Center(
        child: Icon(
          Icons.remove_circle_outline_rounded,
          color: colors.mutedText,
          size: 16,
        ),
      );
    }

    return Text(
      value,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isPro ? neonBlue : colors.secondaryText,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============================================================
  // FREE INFO CARD
  // ============================================================

  Widget _buildFreeInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: neonBlue.withOpacity(.045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: neonBlue.withOpacity(.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoIcon(Icons.card_giftcard_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.subscriptionFreeInfoTitle,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.subscriptionFreeInfoDescription,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIVE PRO
  // ============================================================

  Widget _buildActiveSubscriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: neonGreen.withOpacity(.045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: neonGreen.withOpacity(.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: neonGreen.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: neonGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.subscriptionActiveTitle,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.subscriptionActiveDescription,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRO INFO
  // ============================================================

  Widget _buildProInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: neonBlue.withOpacity(.045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: neonBlue.withOpacity(.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoIcon(Icons.workspace_premium_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.subscriptionProInfoTitle,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.subscriptionProInfoDescription,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: neonBlue.withOpacity(.10),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: neonBlue,
        size: 22,
      ),
    );
  }

  // ============================================================
  // PRIMARY BUTTON
  // ============================================================

  Widget _buildPrimaryButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _purchaseLoading || _storeLoading ? null : onTap,
        icon: Icon(icon, size: 20),
        label: _purchaseLoading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: neonBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECONDARY BUTTON
  // ============================================================

  Widget _buildSecondaryButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: neonBlue, size: 19),
        label: Text(
          title,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CANCEL BUTTON
  // ============================================================

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _showComingSoon,
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: neonRed,
          size: 19,
        ),
        label: Text(
          l10n.subscriptionCancelSubscription,
          style: const TextStyle(
            color: neonRed,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: neonRed.withOpacity(.30),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TEMPORARY
  // ============================================================

  void _showComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.subscriptionManagementComingSoon),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
