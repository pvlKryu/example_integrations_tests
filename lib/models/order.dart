class OrderResult {
  const OrderResult({
    required this.orderNumber,
    required this.totalKopecks,
  });

  final String orderNumber;
  final int totalKopecks;

  factory OrderResult.fromJson(Map<String, dynamic> json) {
    return OrderResult(
      orderNumber: json['orderNumber'] as String,
      totalKopecks: json['totalKopecks'] as int,
    );
  }
}
