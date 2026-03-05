import 'dart:convert';
import 'package:beauty_app/models/product_detail.dart';
import 'package:beauty_app/models/product_model.dart';
import 'package:beauty_app/services/config.dart';
import 'package:http/http.dart' as http;

class APIService {
  static final client = http.Client();

  static Map<String, String> getHeaders() {
    final basicAuth = 'Basic ${base64Encode(
      utf8.encode("${Config.consumerKey}:${Config.consumerSecret}"),
    )}';

    return {
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };
  }

  static Map<String, String> getPublicHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }

static Future<List<Productsmodel>> fetchProductsByCategory({
  required String categoryId, // Ensure this is a numeric ID string, e.g., "15"
  int page = 1,
  int perPage = 10,
}) async {
  // If your ID is coming in as "0" or empty, the API will return nothing.
  if (categoryId.isEmpty || categoryId == "0") {
    print("⚠️ Warning: categoryId is empty or zero.");
  }

  final queryParams = {
    'category': categoryId, // WooCommerce uses 'category' for IDs
    'page': page.toString(),
    'per_page': perPage.toString(),
    'status': 'publish', // Added to ensure only live products show
  };

  final queryString = Uri(queryParameters: queryParams).query;
  final requestUrl = "${Config.baseUrl}${Config.apiPath}${Config.productsURL}?$queryString";

  print("🌐 Requesting: $requestUrl");

  try {
    final response = await client.get(
      Uri.parse(requestUrl),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      print("✅ API returned ${list.length} products for category $categoryId");
      return list.map((e) => Productsmodel.fromJson(e)).toList();
    }
  } catch (e) {
    print("🚨 API Error: $e");
  }
  return [];
}

static Future<List<Productsmodel>> fetchProducts({
  int page = 1,
  int perPage = 33, 
  int? categoryId, 
  String? search,
}) async {
  final queryParams = {
    'page': page.toString(),
    'per_page': perPage.toString(),
    'orderby': 'date',
    'order': 'desc',
    if (search != null && search.isNotEmpty) 'search': search,
    if (categoryId != null) 'category': categoryId.toString(), 
  };

  final queryString = Uri(queryParameters: queryParams).query;

  final requestUrl =
      "${Config.baseUrl}${Config.apiPath}${Config.productsURL}?$queryString";

  print("🌐 [API] Fetch products → Page: $page | Category: $categoryId");

  try {
    final response = await client.get(
      Uri.parse(requestUrl),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);

      print(
          "✅ [API] Products fetched: ${list.length} items");

      return list
          .map((e) => Productsmodel.fromJson(e))
          .toList();
    } else {
      print(
          "❌ [API] Error ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    print("🚨 [API] fetchProducts error: $e");
  }

  return [];
}


  static Future<ProductDetail?> fetchSingleProductDetail(
    String productId,
  ) async {
    final requestUrl =
        "${Config.baseUrl}${Config.apiPath}${Config.productsURL}/$productId";

    try {
      final response = await client.get(
        Uri.parse(requestUrl),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        return ProductDetail.fromJson(json);
      }
    } catch (_) {}

    return null;
  }
static Future<List<Productsmodel>> fetchProductsByIds(
    List<int> productIds,
  ) async {
    if (productIds.isEmpty) return [];

    final queryParams = {
      'include': productIds.join(','),
      'per_page': productIds.length.toString(),
    };

    final queryString = Uri(queryParameters: queryParams).query;

    final requestUrl =
        "${Config.baseUrl}${Config.apiPath}${Config.productsURL}?$queryString";

    try {
      final response = await client.get(
        Uri.parse(requestUrl),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list
            .map((e) => Productsmodel.fromJson(e))
            .toList();
      }
    } catch (_) {}

    return [];
  }






}
