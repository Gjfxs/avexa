import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../models/message.dart';
import '../services/crypto_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../services/saved_messages_service.dart';

class AiTradingAssistantScreen extends StatefulWidget {
  const AiTradingAssistantScreen({super.key});

  @override
  State<AiTradingAssistantScreen> createState() =>
      _AiTradingAssistantScreenState();
}

class _AiTradingAssistantScreenState
    extends State<AiTradingAssistantScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  late AnimationController dotsController;

  final Set<int> likedMessages = {};
  final Set<int> savedMessages = {};

  String? assistantMessage;

  final List<ChatMessage> messages = [];

  final CryptoService aiService = CryptoService();

  final SavedMessagesService savedService =
      SavedMessagesService();

  bool isTyping = false;
  bool showSavedMessages = false;

  String streamedReply = '';
  bool isStreaming = false;

  String typingMessage = 'Analyzing market...';

  AppLocalizations get l10n =>
      AppLocalizations.of(context)!;

  void showAssistantMessage(String message) {
    setState(() {
      assistantMessage = message;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        assistantMessage = null;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  List<Map<String, String>> buildConversationHistory() {
    final history = <Map<String, String>>[];

    final start =
        messages.length > 10 ? messages.length - 10 : 0;

    for (int i = start; i < messages.length; i++) {
      history.add({
        'role': messages[i].isUser ? 'user' : 'assistant',
        'content': messages[i].text,
      });
    }

    return history;
  }

  Future<List<String>> loadSavedMessages() async {
    return await savedService.loadMessages();
  }

  Future<void> sendMessage(String text) async {
    if (isTyping || isStreaming) return;
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          isUser: true,
          text: text,
        ),
      );

      isTyping = true;
    });

    scrollToBottom();
    messageController.clear();

    await Future.delayed(const Duration(seconds: 2));

    final history = buildConversationHistory();

    history.add({
      'role': 'user',
      'content': text,
    });

    final reply = await aiService.generateReply(history);

    if (!mounted) return;

    setState(() {
      isTyping = false;
    });

    await Future.delayed(
      const Duration(milliseconds: 150),
    );

    await streamReply(reply);
  }

  Future<void> regenerateLastAnswer() async {
    if (messages.length < 2) return;

    final lastUser = messages.lastWhere((m) => m.isUser);

    messages.removeLast();

    setState(() {
      isTyping = true;
    });

    scrollToBottom();

    await Future.delayed(const Duration(seconds: 1));

    final history = buildConversationHistory();

    history.add({
      'role': 'user',
      'content': lastUser.text,
    });

    final reply = await aiService.generateReply(history);

    if (!mounted) return;

    setState(() {
      isTyping = false;
      isStreaming = false;
      streamedReply = '';
    });

    await streamReply(reply);
  }

  void scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (!scrollController.hasClients) return;

        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      },
    );
  }

  Future<void> streamReply(String fullText) async {
    setState(() {
      isTyping = false;
      isStreaming = true;
      streamedReply = '';

      messages.add(
        ChatMessage(
          isUser: false,
          text: '',
        ),
      );
    });

    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(
        Duration(
          milliseconds: fullText[i] == ' '
              ? 8
              : fullText[i] == '.'
                  ? 130
                  : fullText[i] == ','
                      ? 80
                      : fullText[i] == '\n'
                          ? 150
                          : 18,
        ),
      );

      if (!mounted) return;

      setState(() {
        streamedReply += fullText[i];
        messages.last.text = streamedReply;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    }

    HapticFeedback.lightImpact();

    if (!mounted) return;

    setState(() {
      isTyping = false;
      isStreaming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
          bottom: Radius.circular(30),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),

                  // HEADER

                  Row(
                    children: [
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                        tooltip: l10n.aiAssistantMinimize,
                      ),
                      Expanded(
                        child: Text(
                          l10n.aiAssistantTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            messages.clear();
                            likedMessages.clear();
                            savedMessages.clear();
                            streamedReply = '';
                            isTyping = false;
                            isStreaming = false;
                          });
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          color: colors.secondaryText,
                        ),
                        tooltip: l10n.aiAssistantClearChat,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    l10n.aiAssistantSubtitle,
                    style: GoogleFonts.poppins(
                      color: colors.secondaryText,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PROMPT CHIPS

                  if (!showSavedMessages)
                    SizedBox(
                      height: 46,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showSavedMessages = true;
                              });
                            },
                            child: Container(
                              width: 52,
                              height: 46,
                              margin: const EdgeInsets.only(
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                color: colors.card,
                                borderRadius:
                                    BorderRadius.circular(18),
                                border: Border.all(
                                  color: colors.border,
                                ),
                              ),
                              child: const Icon(
                                Icons.bookmark_border,
                                color: Colors.amber,
                                size: 24,
                              ),
                            ),
                          ),
                          promptChip(
                            l10n.aiAssistantAnalyzeBtc,
                            colors,
                          ),
                          promptChip(
                            l10n.aiAssistantBestTrade,
                            colors,
                          ),
                          promptChip(
                            l10n.aiAssistantMarketRisk,
                            colors,
                          ),
                          promptChip(
                            l10n.aiAssistantHiddenGems,
                            colors,
                          ),
                        ],
                      ),
                    ),

                  if (!showSavedMessages)
                    const SizedBox(height: 20),

                  // CHAT / SAVED MESSAGES

                  Expanded(
                    child: showSavedMessages
                        ? buildSavedMessages(colors)
                        : buildChat(colors),
                  ),

                  // INPUT

                  if (!showSavedMessages)
                    buildInputBar(colors),
                ],
              ),

              // ASSISTANT TOAST

              if (assistantMessage != null)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 90,
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedOpacity(
                        opacity:
                            assistantMessage != null ? 1.0 : 0.0,
                        duration:
                            const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius:
                                BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.border,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    neonBlue.withOpacity(.08),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bookmark,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                assistantMessage!,
                                style: GoogleFonts.poppins(
                                  color: colors.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
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

  // CHAT

  Widget buildChat(AvexaColors colors) {
    return messages.isEmpty
        ? ListView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 30,
            ),
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/mascot/avexa_ai_head.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.aiAssistantWelcome,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              suggestionCard(
                l10n.aiAssistantAnalyzeBitcoin,
                colors,
              ),
              const SizedBox(height: 12),
              suggestionCard(
                l10n.aiAssistantSuggestionMarketRisk,
                colors,
              ),
              const SizedBox(height: 12),
              suggestionCard(
                l10n.aiAssistantSuggestionHiddenGems,
                colors,
              ),
              const SizedBox(height: 20),
            ],
          )
        : ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: messages.length + (isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == messages.length && isTyping) {
                return const TypingIndicator();
              }

              final message = messages[index];

              if (!message.isUser && message.text.isEmpty) {
                return const TypingIndicator();
              }

              return ChatBubble(
                isUser: message.isUser,
                text: message.text,
                isLiked: likedMessages.contains(index),
                isSaved: savedMessages.contains(index),
                onSave: () async {
                  final wasSaved =
                      savedMessages.contains(index);

                  if (wasSaved) {
                    await savedService.deleteMessage(
                      message.text,
                    );

                    if (!mounted) return;

                    setState(() {
                      savedMessages.remove(index);
                    });

                    showAssistantMessage(
                      l10n.aiAssistantAnalysisRemoved,
                    );
                  } else {
                    await savedService.saveMessage(
                      message.text,
                    );

                    if (!mounted) return;

                    setState(() {
                      savedMessages.add(index);
                    });

                    showAssistantMessage(
                      l10n.aiAssistantAnalysisSaved,
                    );
                  }
                },
                onLike: message.isUser
                    ? null
                    : () {
                        setState(() {
                          likedMessages.add(index);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.aiAssistantFeedbackThanks,
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                onRegenerate: message.isUser
                    ? null
                    : () {
                        regenerateLastAnswer();
                      },
                onDislike: message.isUser
                    ? null
                    : () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: colors.card,
                          shape:
                              const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          builder: (_) {
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.aiAssistantFeedbackQuestion,
                                    style: GoogleFonts.poppins(
                                      color: colors.primaryText,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  feedbackTile(
                                    l10n.aiAssistantFeedbackIncorrect,
                                    colors,
                                  ),
                                  feedbackTile(
                                    l10n.aiAssistantFeedbackGeneric,
                                    colors,
                                  ),
                                  feedbackTile(
                                    l10n.aiAssistantFeedbackNoAnswer,
                                    colors,
                                  ),
                                  feedbackTile(
                                    l10n.aiAssistantFeedbackOutdated,
                                    colors,
                                  ),
                                  feedbackTile(
                                    l10n.aiAssistantFeedbackOther,
                                    colors,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            );
                          },
                        );
                      },
              );
            },
          );
  }

  // SAVED MESSAGES

  Widget buildSavedMessages(AvexaColors colors) {
    return FutureBuilder<List<String>>(
      future: loadSavedMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: neonBlue,
            ),
          );
        }

        final saved = snapshot.data ?? [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        showSavedMessages = false;
                      });
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l10n.aiAssistantSavedAnalyses,
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${saved.length}',
                    style: GoogleFonts.poppins(
                      color: neonBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (saved.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    l10n.aiAssistantNoSavedAnalyses,
                    style: GoogleFonts.poppins(
                      color: colors.mutedText,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            if (saved.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  itemCount: saved.length,
                  itemBuilder: (context, index) {
                    final message = saved[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await savedService.deleteMessage(message);

                              if (!mounted) return;

                              final messageIndex =
                                  messages.indexWhere(
                                (item) => item.text == message,
                              );

                              if (messageIndex != -1) {
                                savedMessages.remove(messageIndex);
                              }

                              showAssistantMessage(
                                l10n.aiAssistantAnalysisRemoved,
                              );

                              setState(() {});
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.bookmark,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              message,
                              style: GoogleFonts.poppins(
                                color: colors.primaryText,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  // PROMPT CHIP

  Widget promptChip(
    String text,
    AvexaColors colors,
  ) {
    return GestureDetector(
      onTap: isTyping || isStreaming
          ? null
          : () {
              sendMessage(text);
            },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
          ),
        ),
      ),
    );
  }

  // SUGGESTION CARD

  Widget suggestionCard(
    String text,
    AvexaColors colors,
  ) {
    return GestureDetector(
      onTap: isTyping || isStreaming
          ? null
          : () {
              sendMessage(text);
            },
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: neonBlue.withOpacity(.025),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // INPUT BAR

  Widget buildInputBar(AvexaColors colors) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                onSubmitted: sendMessage,
                style: TextStyle(
                  color: colors.primaryText,
                ),
                cursorColor: neonBlue,
                decoration: InputDecoration(
                  hintText: l10n.aiAssistantInputHint,
                  hintStyle: TextStyle(
                    color: colors.secondaryText,
                  ),
                  filled: true,
                  fillColor: colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: neonBlue,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: neonBlue,
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: isTyping || isStreaming
                    ? null
                    : () {
                        sendMessage(messageController.text);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FEEDBACK

  Widget feedbackTile(
    String title,
    AvexaColors colors,
  ) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.aiAssistantFeedbackThanksImprove,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: colors.primaryText,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colors.mutedText,
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    dotsController.dispose();
    super.dispose();
  }
}