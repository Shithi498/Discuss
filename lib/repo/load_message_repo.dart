import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/load_message_model.dart';

class LoadMessageRepo {
  final String baseUrl;
  final String sessionCookie; // e.g. "session_id=xyz"

  LoadMessageRepo({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Cookie": sessionCookie,
  };

  Future<loadMessageThreadResult> fetchMessages({
    required int threadId,
    int limit = 50,
    int offset = 0,
  }) async {
    final url = Uri.parse("$baseUrl/api/discuss/channels/messages");

    final body = jsonEncode({
      "jsonrpc": "2.0",
      "params": {
        "thread_id": threadId,
        "limit": limit,
        "offset": offset,
      }
    });

    final response = await http.post(url, headers: _headers, body: body);
print("load msg");
print(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load messages. Status: ${response.statusCode}. Body: ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return loadMessageThreadResult.fromJson(decoded);
  }
}
