import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'package:flutter/services.dart';
import 'typing_indicator.dart';

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String text;
  final VoidCallback? onRegenerate;
  final VoidCallback? onLike;
  final bool isLiked;
  final VoidCallback? onDislike;
  final VoidCallback? onSave;
  final bool isSaved;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.text,
    required this.isLiked,
    required this.isSaved,
    this.onLike,
    this.onDislike,
    this.onSave,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;

    if (!isUser && text.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: neonBlue.withOpacity(.035),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const TypingIndicator(),
        ),
      );
    }

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(
          maxWidth: 320,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? neonBlue
              : colors.card,
          borderRadius: BorderRadius.circular(18),
          border: isUser
              ? null
              : Border.all(
                  color: colors.border,
                ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? neonBlue.withOpacity(.12)
                  : neonBlue.withOpacity(.025),
              blurRadius: isUser ? 16 : 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                color: isUser
                    ? Colors.white
                    : colors.primaryText,
                height: 1.5,
              ),
            ),

            if (!isUser) ...[
              const SizedBox(height: 12),

              Row(
                children: [
                  IconButton(
                    onPressed: onLike,
                    icon: AnimatedScale(
                      scale: isLiked ? 1.15 : 1,
                      duration:
                          const Duration(milliseconds: 180),
                      child: Icon(
                        isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_alt_outlined,
                        size: 18,
                        color: isLiked
                            ? neonGreen
                            : colors.mutedText,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: onDislike,
                    icon: Icon(
                      Icons.thumb_down_alt_outlined,
                      size: 18,
                      color: colors.mutedText,
                    ),
                  ),

                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: text),
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Copied to clipboard",
                          ),
                          duration:
                              const Duration(seconds: 1),
                          behavior:
                              SnackBarBehavior.floating,
                          backgroundColor:
                              colors.elevatedCard,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            side: BorderSide(
                              color: colors.border,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.copy,
                      size: 18,
                      color: colors.mutedText,
                    ),
                  ),

                  IconButton(
                    onPressed: onSave,
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      size: 18,
                      color: isSaved
                          ? Colors.amber
                          : colors.mutedText,
                    ),
                  ),

                  IconButton(
                    onPressed: onRegenerate,
                    icon: Icon(
                      Icons.refresh,
                      size: 18,
                      color: colors.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}