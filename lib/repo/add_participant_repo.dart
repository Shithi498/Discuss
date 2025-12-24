import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/add_participant.dart';

class AddParticipantRepo {
  final String baseUrl;
  final String sessionCookie; // e.g. "session_id=xyz"

  AddParticipantRepo({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Cookie": sessionCookie,
  };

  Future<AddParticipant> addParticipant({
    required int threadId,
    required int partnerId,
  }) async {
    final url = Uri.parse("$baseUrl/api/discuss/channel/add_participant");

    final body = jsonEncode({
      "jsonrpc": "2.0",
      "params": {
        "thread_id": threadId,
        "partner_id": partnerId,
      }
    });

    final response = await http.post(url, headers: _headers, body: body);

    print("add participant");
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to add participant. Status: ${response.statusCode}. Body: ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return AddParticipant.fromJson(decoded);
  }
}
