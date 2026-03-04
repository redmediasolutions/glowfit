class Productsmodel {
  final int id;
  final String name;
  final String? brand;
  final String? image;
  final double? regularPrice;
  final double? salePrice;
  final List<int> categoryIds;
  final bool isNotForSale;
  final bool canAddToCart;

  Productsmodel({
    required this.id, required this.name, this.brand,  
    this.image, this.regularPrice, this.salePrice, 
    required this.categoryIds, required this.isNotForSale, required this.canAddToCart,
  });

  factory Productsmodel.fromJson(Map<String, dynamic> json) {
    
  
   final List<int> categoryIds = (json['categories'] as List?)
          ?.map((e) => e['id'] as int) // Extract the 'id' from each category object
          .toList() ?? [];
    final bool isNotForSale = categoryIds.contains(94);
    final bool manageStock = json['manage_stock'] == true;
    final int? stockQuantity = json['stock_quantity'] != null ? int.tryParse(json['stock_quantity'].toString()) : null;

    return Productsmodel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
   
      image: (json['images'] is List && json['images'].isNotEmpty) ? json['images'][0]['src']?.toString() : null,
      regularPrice: _parseDouble(json['regular_price']),
      salePrice: _parseDouble(json['sale_price']),
     
      categoryIds: categoryIds,
      isNotForSale: isNotForSale,
      canAddToCart: !(manageStock && (stockQuantity ?? 0) < 1) && !isNotForSale,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}