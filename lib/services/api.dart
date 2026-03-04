import 'dart:convert';
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

static Future<List<Productsmodel>> fetchAllProducts() async {
  final requestUrl = "${Config.baseUrl}${Config.apiPath}${Config.productsURL}";
  try {
    final response = await client.get(Uri.parse(requestUrl), headers: getHeaders());
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => Productsmodel.fromJson(e)).toList();
    }
  } catch (e) {
    print(e);
  }
  return [];
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
