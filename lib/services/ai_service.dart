class AiService {

  Future<String> generateReply(String question) async {

    final q = question.toLowerCase();

    if (q.contains("btc")) {
      return "Bitcoin remains bullish.\n\nSupport: \$65,000\nResistance: \$70,000\nAI Confidence: 87%";
    }

    if (q.contains("eth")) {
      return "Ethereum remains strong.\n\nETF inflows stay positive.\nAI Confidence: 84%";
    }

    if (q.contains("sol")) {
      return "Solana has strong momentum.\n\nWhale accumulation detected.\nAI Confidence: 91%";
    }

    if (q.contains("pepe")) {
      return "PEPE remains highly volatile.\nMomentum is positive but risk is elevated.";
    }

    return "Current market sentiment is neutral. Wait for confirmation before entering.";
  }
}