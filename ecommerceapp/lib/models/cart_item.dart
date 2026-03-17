class CartItem {
  final String productId;
  final String name;
  final double price;
  final String image;
  int qty;

  CartItem({required this.productId, required this.name, required this.price, required this.image, this.qty = 1});

  factory CartItem.fromMap(Map<String, dynamic> m) {
    return CartItem(
      productId: m['productId'] ?? '',
      name: m['name'] ?? '',
      price: (m['price'] ?? 0).toDouble(),
      image: m['image'] ?? '',
      qty: (m['qty'] ?? 1),
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'name': name,
    'price': price,
    'image': image,
    'qty': qty,
  };
}
