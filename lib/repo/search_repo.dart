import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/search_model.dart';


class SearchRepo {
  final String baseUrl;
  final String sessionCookie;

  SearchRepo({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Cookie": sessionCookie,
  };



  Future<List<Search>> searchPartners({String query = ""}) async {
    final url = Uri.parse("$baseUrl/api/messaging/partners/search");

    final payload = {
      "jsonrpc": "2.0",
      "params": {
        "query": query,
      }
    };
    print('🔎 SEARCH URL: $url');
    print('🔎 SEARCH PAYLOAD: $payload');

    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(payload),
    );
    print('🔎 SEARCH STATUS: ${res.statusCode}');
    print('🔎 SEARCH BODY: ${res.body}');
    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    final result = decoded is Map<String, dynamic>
        ? (decoded["result"] as Map<String, dynamic>? ?? decoded)
        : <String, dynamic>{};

    final partners = (result["partners"] as List? ?? const [])
        .map((p) => Search.fromMap(p))
        .toList();

    return partners;

  }
}
