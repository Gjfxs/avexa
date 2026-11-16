import 'package:flutter/material.dart';
import '../theme.dart';
import '../screens/ai_trading_assistant_screen.dart';

class FloatingAiAssistant extends StatefulWidget {
  const FloatingAiAssistant({
    super.key,
  });

  @override
  State<FloatingAiAssistant> createState() =>
      _FloatingAiAssistantState();
}

class _FloatingAiAssistantState
    extends State<FloatingAiAssistant>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;

  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 250,
      ),
    );

    scaleAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutBack,
    );
  }

  void toggleAssistant() {
    setState(() {
      isOpen = !isOpen;
    });

    if (isOpen) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    return Stack(
      children: [
        if (isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: toggleAssistant,
              child: Container(
                color: Colors.black.withOpacity(.18),
              ),
            ),
          ),

        if (isOpen)
          Positioned(
            left: 12,
            right: 12,
            bottom: 85,
            top: 80,
            child: ScaleTransition(
              scale: scaleAnimation,
              alignment: Alignment.bottomRight,
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(28),
                  child:
                      const AiTradingAssistantScreen(),
                ),
              ),
            ),
          ),

        Positioned(
          right: 20,
          bottom: 25,
          child: GestureDetector(
            onTap: toggleAssistant,
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 250),
              width: isOpen ? 52 : 60,
              height: isOpen ? 52 : 60,
              decoration: BoxDecoration(
                color: isOpen
                    ? colors.card
                    : neonBlue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: neonBlue.withOpacity(.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        neonBlue.withOpacity(.25),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                isOpen
                    ? Icons.close
                    : Icons.auto_awesome,
                color: Colors.white,
                size: isOpen ? 24 : 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}