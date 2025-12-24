import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ReadMessageRepo with ChangeNotifier {
  final String baseUrl;
  final String sessionCookie;

  ReadMessageRepo({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Cookie": sessionCookie,
  };

  String? error;

//   Future<int?> markThreadAsRead({
//     required int msgId,
//     required int threadId,
//   }) async {
//     try {
//       final url = Uri.parse("$baseUrl/api/discuss/message/read");
//       print("url");
// print(url);
//
//       final body = jsonEncode({
//         "jsonrpc": "2.0",
//         "params": {
//           "thread_id": threadId,
//           "message_ids": [msgId],
//
//         },
//       });
//
//       final res = await http.post(
//         url,
//         headers: _headers,
//         body: body,
//       );
//       print("Read");
// print(res.body);
//       if (res.statusCode != 200) {
//         error = "Failed to mark as read (${res.statusCode})";
//         return null;
//       }
//
//       final data = jsonDecode(res.body);
//
//       if (data["result"]?["success"] == true) {
//         final markedCount = data["result"];
//       //  final markedCount = data["result"]["marked_count"] as int?;
//         debugPrint("✅ Marked $markedCount messages as read");
//         return markedCount;
//       } else {
//         error = "Server returned error while marking read";
//         return null;
//       }
//     } catch (e) {
//       error = "Error marking messages as read: $e";
//       return null;
//     }
//   }
  Future<bool> markThreadAsRead({
    required int msgId,
    required int threadId,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/api/discuss/message/read");

      final body = jsonEncode({
        "jsonrpc": "2.0",
        "params": {
          "thread_id": threadId,
          "message_ids": [msgId],
        },
      });

      final res = await http.post(url, headers: _headers, body: body);
print("Read msges: ${res.body}");
      if (res.statusCode != 200) {
        error = "Failed (${res.statusCode})";
        return false;
      }

      final data = jsonDecode(res.body);

      return data["result"]?["success"]  ;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }


}
