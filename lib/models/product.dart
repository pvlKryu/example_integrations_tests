class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceKopecks,
  });

  final String id;
  final String name;
  final String description;
  final int priceKopecks;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      priceKopecks: json['priceKopecks'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'priceKopecks': priceKopecks,
      };
}
