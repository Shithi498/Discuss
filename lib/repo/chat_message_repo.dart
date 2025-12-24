import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/chat_message_model.dart';
class MessageRepo {
  final String baseUrl;
  final String sessionCookie;

  MessageRepo({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Cookie": sessionCookie,
  };


  // Future<SendMessageResponse> sendMessage({
  //   required int threadId,
  //   required String body,
  //
  // }) async {
  //   final url = Uri.parse('$baseUrl/api/discuss/messages/send');
  //
  //   final payload = {
  //     "jsonrpc": "2.0",
  //     "params": {
  //       "thread_id":threadId ,
  //
  //       "body": body,
  //     }
  //   };
  //
  //   final response = await http.post(
  //     url,
  //     headers: _headers,
  //     body: jsonEncode(payload),
  //   );
  //
  //   if (response.statusCode != 200) {
  //     throw Exception(
  //         'Failed to send message. Status: ${response.statusCode}. Body: ${response.body}');
  //   }
  //
  //   final Map<String, dynamic> data = jsonDecode(response.body);
  //   return SendMessageResponse.fromJson(data);
  // }

  // Future<SendMessageResponse> sendMessage({
  //   required int threadId,
  //   required String body,
  //   List<int> attachmentIds = const [],
  // }) async {
  //   final url = Uri.parse('$baseUrl/api/discuss/messages/send');
  //
  //   final payload = {
  //     "jsonrpc": "2.0",
  //     "params": {
  //       "thread_id": threadId,
  //       "body": body,
  //       if (attachmentIds.isNotEmpty) "attachment_ids": attachmentIds,
  //     }
  //   };
  //
  //   final response = await http.post(
  //     url,
  //     headers: _headers,
  //     body: jsonEncode(payload),
  //   );
  //   print("send msg");
  //   print(response.body);
  //   if (response.statusCode != 200) {
  //     throw Exception(
  //       'Failed to send message. Status: ${response.statusCode}. Body: ${response.body}',
  //     );
  //   }
  //
  //   final Map<String, dynamic> data = jsonDecode(response.body);
  //   return SendMessageResponse.fromJson(data);
  // }

  Future<SendMessageResponse> sendMessage({
    required int threadId, // keep your app param name
    required String body,
    List<int> attachmentIds = const [],
  }) async {
    final url = Uri.parse('$baseUrl/api/discuss/messages/send');


    final safeBody = body.trim().isEmpty ? "Attachment" : body;

    final payload = {
      "jsonrpc": "2.0",
      "params": {
        "channel_id": threadId,
        "body": safeBody,
        if (attachmentIds.isNotEmpty) "attachment_ids": attachmentIds,
      }
    };

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(payload),
    );

    print("SEND PAYLOAD: ${jsonEncode(payload)}");
    print("SEND RESPONSE: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to send message. Status: ${response.statusCode}. Body: ${response.body}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return SendMessageResponse.fromJson(data);
  }



}
