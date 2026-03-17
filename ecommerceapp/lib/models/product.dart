class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String description;
  final String category;
  final double? rating;
  final int? ratingCount;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
    this.rating,
    this.ratingCount,
  });

  factory Product.fromData(String id, Map<String, dynamic> data) {
    final ratingData = data['rating'] as Map<String, dynamic>?;

    return Product(
      id: id.isNotEmpty ? id : (data['id'] ?? ''),
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      rating: ratingData != null
          ? (ratingData['rate'] as num?)?.toDouble()
          : null,
      ratingCount: ratingData != null ? (ratingData['count'] as int?) : null,
    );
  }
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'image': image,
    'description': description,
    'category': category,
    'rating': rating == null ? null : {'rate': rating, 'count': ratingCount},
  };
}
