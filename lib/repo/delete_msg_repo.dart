import 'dart:convert';
import 'package:http/http.dart' as http;

class DeleteMessageRepo {
  final String baseUrl;
  final String sessionCookie; // e.g. "session_id=xyz"

  DeleteMessageRepo({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Cookie": sessionCookie,
  };

  Future<bool> deleteMessage({
    required int messageId,
  }) async {
    final url = Uri.parse("$baseUrl/api/discuss/message/delete");

    final body = jsonEncode({
      "jsonrpc": "2.0",
      "params": {
        "message_id": messageId,
      }
    });

    final response = await http.post(url, headers: _headers, body: body);

    print("delete msg");
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to delete message. "
            "Status: ${response.statusCode}. Body: ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final result = decoded["result"] as Map<String, dynamic>?;

    return result?["success"] == true;
  }
}
