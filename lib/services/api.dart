import 'dart:convert';
import 'package:beauty_app/services/config.dart';
import 'package:flutter/foundation.dart';
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



}
