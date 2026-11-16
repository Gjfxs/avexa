import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/first_launch_service.dart';
import '../services/subscription_purchase_service.dart';
import '../services/subscription_service.dart';
import '../theme.dart';
import 'main_screen.dart';

class PlanSelectionScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const PlanSelectionScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  State<PlanSelectionScreen> createState() =>
      _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  final SubscriptionPurchaseService _purchaseService =
      SubscriptionPurchaseService.instance;

  bool _loading = true;
  bool _processing = false;
  String? _selectedPlan;

  AvexaColors get colors =>
      Theme.of(context).extension<AvexaColors>()!;

  @override
  void initState() {
    super.initState();
    _initializeStore();
  }

  Future<void> _initializeStore() async {
    try {
      await _purchaseService.initialize();
    } catch (error) {
      debugPrint('PLAN SELECTION STORE ERROR: $error');
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _continueFree() async {
    if (_processing) return;

    setState(() {
      _processing = true;
      _selectedPlan = 'FREE';
    });

    try {
      await FirstLaunchService.instance
          .markSubscriptionStepCompleted();

      if (!mounted) return;
      widget.onCompleted();
    } catch (error) {
      debugPrint('FREE PLAN SAVE ERROR: $error');

      if (!mounted) return;

      setState(() {
        _processing = false;
        _selectedPlan = null;
      });

      _showMessage(
        'Could not save your selection. Please try again.',
      );
    }
  }

  Future<void> _purchasePlan({required bool yearly}) async {
    if (_processing || _loading) return;

    setState(() {
      _processing = true;
      _selectedPlan = yearly ? 'YEARLY' : 'MONTHLY';
    });

    try {
      final started = yearly
          ? await _purchaseService.purchaseYearly()
          : await _purchaseService.purchaseMonthly();

      if (!mounted) return;

      if (!started) {
        setState(() {
          _processing = false;
          _selectedPlan = null;
        });

        _showMessage(
          'This purchase is currently unavailable. Please try again.',
        );
        return;
      }

      // Starting a purchase does not mean it has been confirmed.
      final isPro = await SubscriptionService.isPro();

      if (!mounted) return;

      if (isPro) {
        await FirstLaunchService.instance
            .markSubscriptionStepCompleted();

        if (!mounted) return;
        widget.onCompleted();
        return;
      }

      // Keep the existing asynchronous purchase behaviour.
      setState(() {
        _processing = false;
        _selectedPlan = null;
      });

      _showMessage(
        'Purchase started. Your plan will update when the store confirms it.',
      );
    } catch (error) {
      debugPrint('PLAN PURCHASE ERROR: $error');

      if (!mounted) return;

      setState(() {
        _processing = false;
        _selectedPlan = null;
      });

      _showMessage('Something went wrong. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  TextStyle _textStyle({
    double size = 12,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double height = 1.3,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color ?? colors.primaryText,
      height: height,
    );
  }

  Widget _planCard({
    required String plan,
    required String title,
    required String price,
    required String period,
    required String description,
    required bool yearly,
  }) {
    final selected = _selectedPlan == plan;
    final accent = neonBlue;
    final borderColor = selected || yearly
        ? accent
        : colors.border;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: yearly
              ? accent.withOpacity(.09)
              : colors.card.withOpacity(.65),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: borderColor.withOpacity(
              selected || yearly ? .95 : .8,
            ),
            width: selected || yearly ? 1.5 : 1,
          ),
          boxShadow: yearly
              ? [
                  BoxShadow(
                    color: accent.withOpacity(.09),
                    blurRadius: 18,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 13, 11, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: _textStyle(
                        size: 10,
                        weight: FontWeight.w800,
                        color: yearly
                            ? accent
                            : colors.secondaryText,
                      ),
                    ),
                  ),
                  if (yearly)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(.13),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SAVE 33%',
                        style: _textStyle(
                          size: 7,
                          weight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: neonBlue,
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  price,
                  style: _textStyle(
                    size: 23,
                    weight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                period,
                style: _textStyle(
                  size: 9,
                  color: colors.secondaryText,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                description,
                style: _textStyle(
                  size: 9,
                  color: colors.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 13),
              SizedBox(
                width: double.infinity,
                height: 37,
                child: OutlinedButton(
                  onPressed: _loading || _processing
                      ? null
                      : () => _purchasePlan(yearly: yearly),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    side: BorderSide(
                      color: yearly
                          ? accent.withOpacity(.45)
                          : colors.border,
                    ),
                    backgroundColor:
                        yearly ? accent : Colors.transparent,
                    foregroundColor:
                        yearly ? Colors.white : colors.primaryText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: _processing && selected
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: neonBlue,
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            yearly ? 'Choose Yearly' : 'Choose Monthly',
                            style: _textStyle(
                              size: 10,
                              weight: FontWeight.w700,
                              color: yearly
                                  ? Colors.white
                                  : colors.primaryText,
                            ),
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

  Widget _benefit(IconData icon, String text) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: neonBlue,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: _textStyle(
                size: 9,
                color: colors.secondaryText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final compact = screenHeight < 750;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: MainScreen(
                key: const ValueKey('plan-selection-background'),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 2,
                sigmaY: 2,
              ),
              child: Container(
                color: Colors.black.withOpacity(.57),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: compact ? 8 : 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 14,
                        sigmaY: 14,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          compact ? 17 : 21,
                          compact ? 18 : 22,
                          compact ? 17 : 21,
                          compact ? 15 : 19,
                        ),
                        decoration: BoxDecoration(
                          color: colors.card.withOpacity(.94),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: neonBlue.withOpacity(.42),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: neonBlue.withOpacity(.10),
                              blurRadius: 35,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'AVEXA',
                                  style: _textStyle(
                                    size: 12,
                                    weight: FontWeight.w800,
                                  ).copyWith(letterSpacing: 2.2),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: neonBlue.withOpacity(.10),
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(
                                      color: neonBlue.withOpacity(.30),
                                    ),
                                  ),
                                  child: Text(
                                    'PRO MEMBERSHIP',
                                    style: _textStyle(
                                      size: 8,
                                      weight: FontWeight.w800,
                                      color: neonBlue,
                                    ).copyWith(letterSpacing: .7),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 16 : 21),
                            Container(
                              width: 43,
                              height: 43,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: neonBlue.withOpacity(.10),
                                border: Border.all(
                                  color: neonBlue.withOpacity(.35),
                                ),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: neonBlue,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 11),
                            Text(
                              'Choose your plan',
                              textAlign: TextAlign.center,
                              style: _textStyle(
                                size: compact ? 23 : 26,
                                weight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Unlock the full power of Avexa and '
                              'take your trading to the next level.',
                              textAlign: TextAlign.center,
                              style: _textStyle(
                                size: 11,
                                color: colors.secondaryText,
                                height: 1.55,
                              ),
                            ),
                            SizedBox(height: compact ? 17 : 22),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _planCard(
                                  plan: 'MONTHLY',
                                  title: 'MONTHLY',
                                  price: _purchaseService
                                          .monthlyProduct?.price ??
                                      '\$9.99',
                                  period: 'per month',
                                  description: 'Flexible monthly billing',
                                  yearly: false,
                                ),
                                const SizedBox(width: 11),
                                _planCard(
                                  plan: 'YEARLY',
                                  title: 'YEARLY',
                                  price: _purchaseService
                                          .yearlyProduct?.price ??
                                      '\$79.99',
                                  period: 'per year',
                                  description: 'Best value for PRO',
                                  yearly: true,
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 14 : 18),
                            Row(
                              children: [
                                _benefit(
                                  Icons.bolt_rounded,
                                  'AI trading tools',
                                ),
                                const SizedBox(width: 8),
                                _benefit(
                                  Icons.insights_rounded,
                                  'More insights',
                                ),
                                const SizedBox(width: 8),
                                _benefit(
                                  Icons.lock_open_rounded,
                                  'PRO access',
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 14 : 18),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: colors.border,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'OR START FREE',
                                    style: _textStyle(
                                      size: 8,
                                      weight: FontWeight.w700,
                                      color: colors.mutedText,
                                    ).copyWith(letterSpacing: 1),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: colors.border,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: OutlinedButton(
                                onPressed: _processing ? null : _continueFree,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: colors.border,
                                  ),
                                  backgroundColor:
                                      colors.card.withOpacity(.45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _processing &&
                                        _selectedPlan == 'FREE'
                                    ? const SizedBox(
                                        width: 17,
                                        height: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: neonBlue,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.rocket_launch_rounded,
                                            size: 17,
                                            color: colors.secondaryText,
                                          ),
                                          const SizedBox(width: 9),
                                          Text(
                                            'Continue with FREE',
                                            style: _textStyle(
                                              size: 11,
                                              weight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start with essential features. Upgrade anytime.',
                              textAlign: TextAlign.center,
                              style: _textStyle(
                                size: 9,
                                color: colors.mutedText,
                              ),
                            ),
                            if (_loading) ...[
                              const SizedBox(height: 12),
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: neonBlue,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}