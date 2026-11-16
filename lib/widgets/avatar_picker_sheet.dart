import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/avatar_service.dart';

class AvatarPickerSheet extends StatelessWidget {
  final bool isPremium;

  const AvatarPickerSheet({
    super.key,
    required this.isPremium,
  });

  final List<String> freeAvatars = const [
    "assets/avatars/free/ax_ansem.png",
    "assets/avatars/free/ax_champange.png",
    "assets/avatars/free/ax_grillz.png",
    "assets/avatars/free/ax_jacuzzi.png",
    "assets/avatars/free/ax_lambo.png",
    "assets/avatars/free/ax_money1.png",
    "assets/avatars/free/ax_money2.png",
    "assets/avatars/free/ax_pengu.png",
    "assets/avatars/free/ax_shiba.png",
    "assets/avatars/free/ax_sim.png",
    "assets/avatars/free/ax_sol.png",
    "assets/avatars/free/ax_standard.png",
    "assets/avatars/free/ax_watch.png",
    "assets/avatars/free/ax_watches.png",
    "assets/avatars/free/ax_womens.png",
  ];

  final List<String> premiumAvatars = const [
    "assets/avatars/premium/ax_liveclub.png",
    "assets/avatars/premium/ax_livejet.png",
    "assets/avatars/premium/ax_livelambo.png",
    "assets/avatars/premium/ax_liverr.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xff10151F),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: ListView(
        children: [

          // HANDLE
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // TITLE
          const Text(
            "Choose Avatar",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 28),

          // FREE
          Row(
            children: const [
              Text(
                "FREE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: freeAvatars.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(
                    context,
                    freeAvatars[index],
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(.15),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      freeAvatars[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 34),

          // PREMIUM HEADER
          Row(
            children: [
              const Text(
                "PREMIUM",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "PRO",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: premiumAvatars.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (!isPremium) {
                    _showPremiumDialog(context);
                    return;
                  }

                  Navigator.pop(
                    context,
                    premiumAvatars[index],
                  );
                },
                child: Stack(
                  children: [

                    ClipOval(
                      child: Image.asset(
                        premiumAvatars[index],
                        fit: BoxFit.cover,
                      ),
                    ),

                    if (!isPremium)
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                      ),

                    if (!isPremium)
                      const Center(
                        child: Icon(
                          Icons.lock_rounded,
                          color: Colors.amber,
                          size: 22,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // OWN PHOTO
          GestureDetector(
            onTap: () async {
              if (!isPremium) {
                _showPremiumDialog(context);
                return;
              }

              final url = await AvatarService.uploadAvatar();

              if (url == null) return;

              if (!context.mounted) return;

              Navigator.pop(context, url);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.amber.withOpacity(.25),
                ),
              ),
              child: Row(
                children: const [

                  Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.amber,
                  ),

                  SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      "Use your own photo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Icon(
                    Icons.lock_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff151A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Premium Feature",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Unlock exclusive Ax avatars and use your own profile picture with AnalyX Premium.",
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "NOT NOW",
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                "UPGRADE",
              ),
            ),
          ],
        );
      },
    );
  }
}