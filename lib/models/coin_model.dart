class CoinModel {

  final String name;
  final String symbol;
  final String image;
  final double price;
  final double change24h;

  CoinModel({
    required this.name,
    required this.symbol,
    required this.image,
    required this.price,
    required this.change24h,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {

    return CoinModel(
      name: json['name'],
      symbol: json['symbol'],
      image: json['image'],
      price: (json['current_price'] as num).toDouble(),
      change24h:
          (json['price_change_percentage_24h'] as num).toDouble(),
    );
  }
}