import 'package:flutter/material.dart';

import '../theme.dart';
import '../screens/ai_trading_assistant_screen.dart';

class FloatingAiBubble extends StatefulWidget {
  const FloatingAiBubble({
    super.key,
  });

  @override
  State<FloatingAiBubble> createState() =>
      _FloatingAiBubbleState();
}

class _FloatingAiBubbleState
    extends State<FloatingAiBubble> {
  double right = 18;
  double bottom = 100;

  bool isDragging = false;

  void _openAssistant() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AI Assistant',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration:
          const Duration(milliseconds: 250),
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        final colors =
            Theme.of(context).extension<AvexaColors>()!;

        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height:
                  MediaQuery.of(context).size.height *
                      0.88,
              margin: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 10,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius:
                    BorderRadius.circular(28),
                border: Border.all(
                  color:
                      neonBlue.withOpacity(0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        neonBlue.withOpacity(0.12),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child:
                  const AiTradingAssistantScreen(),
            ),
          ),
        );
      },
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    return Positioned(
      right: right,
      bottom: bottom,
      child: GestureDetector(
        onTap: isDragging
            ? null
            : _openAssistant,

        onPanStart: (_) {
          setState(() {
            isDragging = true;
          });
        },

        onPanUpdate: (details) {
          final size =
              MediaQuery.of(context).size;

          setState(() {
            right -= details.delta.dx;
            bottom -= details.delta.dy;

            right = right.clamp(
              8.0,
              size.width - 78,
            );

            bottom = bottom.clamp(
              90.0,
              size.height - 100,
            );
          });
        },

        onPanEnd: (_) {
          setState(() {
            isDragging = false;
          });
        },

        child: AnimatedScale(
          scale: isDragging ? 1.08 : 1.0,
          duration:
              const Duration(milliseconds: 120),
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.card,
              border: Border.all(
                color: neonBlue,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      neonBlue.withOpacity(0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: neonBlue,
              size: 29,
            ),
          ),
        ),
      ),
    );
  }
}