class Productsmodel {
  final int id;
  final String name;
  final String? brand;
  final String? image;
  final List<String> galleryImages;
  final String description;
  final String? manufactured;
  final String? composition;
  final String? packagesize;
  final String categories;
  final String? sideeeffects;
  final String? working;
  final double? regularPrice;
  final double? salePrice;
  final List<int> categoryIds;
  final bool isNotForSale;
  final bool canAddToCart;

  Productsmodel({
    required this.id,
    required this.name,
    this.brand,
    this.image,
    required this.galleryImages,
    required this.description,
    required this.categories,
    this.sideeeffects,
    this.working,
    this.regularPrice,
    this.salePrice,
    required this.categoryIds,
    required this.isNotForSale,
    required this.canAddToCart, 
  this.manufactured, 
     this.composition, 
     this.packagesize,
  });

  factory Productsmodel.fromJson(Map<String, dynamic> json) {

    String? sideffects;
    String? howdoesitwork;
String? brandValue;
String? composition;
String? package;


    // Extract meta data
    if (json['meta_data'] is List) {
      for (final item in json['meta_data']) {
        if (item is Map<String, dynamic>) {
          if (item['key'] == 'side_effects') {
            sideffects = _cleanHtml(item['value']);
          } 
          else if (item['key'] == 'how_does_it_work') {
            howdoesitwork = _cleanHtml(item['value']);
          }
        else if (item['key'] == 'composition') {
            composition = _cleanHtml(item['value']);
          }else if (item['key'] == 'package') {
            package = _cleanHtml(item['value']);
          }
          else if (item['key'] == 'manufacturer') {
            brandValue ??= item['value']?.toString();
          }
        }
      }
    }
    if (json['brands'] is List && json['brands'].isNotEmpty) {
      brandValue = json['brands'][0]['name']?.toString() ?? brandValue;
    }


    // Extract gallery images
    List<String> galleryImages = [];

    if (json['images'] is List) {
      galleryImages = (json['images'] as List)
          .map((img) => img['src']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    }

    // Categories
    final List categoriesList =
        json['categories'] is List ? json['categories'] : [];

    final List<int> categoryIds = categoriesList
        .map((e) => int.tryParse(e['id'].toString()) ?? 0)
        .toList();

    final String categoryName = categoriesList.isNotEmpty
        ? categoriesList[0]['name']?.toString() ?? ''
        : '';

    // Stock logic
    final bool isNotForSale = categoryIds.contains(94);
    final bool manageStock = json['manage_stock'] == true;
    final bool isInStock = json['stock_status'] == 'instock';
    final int stockQuantity =
        int.tryParse(json['stock_quantity']?.toString() ?? '0') ?? 0;

    return Productsmodel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categories: categoryName,
      sideeeffects: sideffects,
      working: howdoesitwork,
manufactured: brandValue,
composition: composition,
packagesize: package,
      image: galleryImages.isNotEmpty ? galleryImages.first : null,
      galleryImages: galleryImages,

      regularPrice: _parseDouble(json['regular_price'] ?? json['price']),
      salePrice: _parseDouble(json['sale_price']),
      categoryIds: categoryIds,
      isNotForSale: isNotForSale,
      canAddToCart:
          (isInStock || (manageStock && stockQuantity > 0)) && !isNotForSale,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? _cleanHtml(dynamic value) {
    if (value == null) return null;
    String clean =
        value.toString().replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
    return clean.isEmpty ? null : clean;
  }
}