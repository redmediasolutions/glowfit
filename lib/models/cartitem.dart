class CartItem {
  final String name;
  final String price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  }) {
    // Validation to ensure quantity never starts below 1
    if (this.quantity < 1) this.quantity = 1;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      // Ensure we don't get 'null' as a string literal
      name: map['name']?.toString() ?? 'Unknown Product',
      price: map['price']?.toString() ?? '0.0',
      imageUrl: map['imageUrl']?.toString() ?? '',
      // Ensure quantity is at least 1 when loading from JSON
      quantity: (map['quantity'] != null && map['quantity'] > 0) 
                ? map['quantity'] 
                : 1,
    );
  }
}