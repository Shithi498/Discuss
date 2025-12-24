import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/marked_msg_model.dart';

class MarkedReadRepo{
  final String baseUrl;
  final String sessionCookie;
  MarkedReadRepo({required this.baseUrl, required this.sessionCookie});

  Future<MarkMsgReadResult> markThreadAsRead({
    required int threadId,
 //   required int lastMessageId,
  }) async {
    final uri = Uri.parse("$baseUrl/api/discuss/message/read");

    final body = MarkedMsgModel(
      threadId: threadId,
     // lastMessageId: lastMessageId,
    ).toJsonRpc();

    final res = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Cookie": sessionCookie,
      },
      body: jsonEncode(body),
    );
    print("Marked as read");
print(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Mark as read failed: ${res.statusCode} ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final result = MarkMsgReadResult.fromJson(decoded);

    if (!result.success) {
      throw Exception("Mark as read failed: success=false");
    }

    return result;
  }
}
