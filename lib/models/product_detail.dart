class ProductDetail {
  final int id;
  final String name;
 
 
  final List<String> images;
  final double price;
  final double? salePrice;

  final List<int> relatedProductIds;

  ProductDetail({
    required this.id,
    required this.name,
   
    required this.images,
    required this.price,
    this.salePrice,
   
    required this.relatedProductIds,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    String manufacturer = '';
    String content = '';
    String saltComposition = '';
    String competitor = '';

    /// 🔍 META DATA PARSING
    if (json['meta_data'] is List) {
      for (final item in json['meta_data']) {
        if (item is Map<String, dynamic>) {
          switch (item['key']) {
            case 'manufacturer':
              manufacturer = item['value']?.toString() ?? manufacturer;
              break;

            case 'product_content':
              content = item['value']?.toString() ?? content;
              break;

            case 'salt_composition':
              saltComposition = item['value']?.toString() ?? saltComposition;
              break;

            case 'competitor_product_&_namw':
              competitor = item['value']?.toString() ?? competitor;
              break;
          }
        }
      }
    }

    /// 🏷️ BRAND OVERRIDE
    if (json['brands'] is List && json['brands'].isNotEmpty) {
      final brand = json['brands'][0];
      if (brand is Map<String, dynamic>) {
        manufacturer = brand['name']?.toString() ?? manufacturer;
      }
    }

    /// 🖼️ IMAGES
    final List<String> images =
        (json['images'] as List?)
                ?.map((e) => e['src']?.toString())
                .whereType<String>()
                .toList() ??
            [];

    /// 🔗 RELATED PRODUCT IDS
    final List<int> relatedProductIds =
        (json['related_ids'] as List?)
                ?.map((e) => e is int
                    ? e
                    : int.tryParse(e.toString()))
                .whereType<int>()
                .toList() ??
            [];

    return ProductDetail(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
     
      images: images,
      price: double.tryParse(json['regular_price']?.toString() ?? '') ??
          double.tryParse(json['price']?.toString() ?? '') ??
          0.0,
      salePrice: double.tryParse(json['sale_price']?.toString() ?? ''),
     
      relatedProductIds: relatedProductIds,
    );
  }
}
