import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/channel_participants_model.dart';

class ChannelParticipantsRepo {
  final String baseUrl;
  final String sessionCookie;

  ChannelParticipantsRepo({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Cookie": sessionCookie,
  };

  Future<ChannelParticipants> fetchParticipants({
    required int threadId,
  }) async {
    final url = Uri.parse("$baseUrl/api/discuss/channel/participants");

    final body = jsonEncode({
      "jsonrpc": "2.0",
      "params": {
        "thread_id": threadId,
      }
    });

    final response = await http.post(url, headers: _headers, body: body);

    print("channel participants");
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load participants. "
            "Status: ${response.statusCode}. Body: ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ChannelParticipants.fromJson(decoded);
  }
}
