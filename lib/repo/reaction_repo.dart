import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/reaction.dart';

class ReactionRepo {
  final String baseUrl;
  final String sessionCookie;

  ReactionRepo({
    required this.baseUrl,
    required this.sessionCookie,
  });

  String? error;

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Cookie": sessionCookie,
  };

  Future<ReactionResponse?> toggleReaction({
    required int messageId,
    required String content,
  }) async {
    return _sendReaction(
      messageId: messageId,
      content: content,
      action: "toggle",
    );
  }

  Future<ReactionResponse?> addReaction({
    required int messageId,
    required String content,
  }) async {
    return _sendReaction(
      messageId: messageId,
      content: content,
      action: "add",
    );
  }

  Future<ReactionResponse?> removeReaction({
    required int messageId,
    required String content,
  }) async {
    return _sendReaction(
      messageId: messageId,
      content: content,
      action: "remove",
    );
  }

  Future<ReactionResponse?> _sendReaction({
    required int messageId,
    required String content,
    required String action,
  }) async {
    error = null;

    try {
      final url = Uri.parse("$baseUrl/api/discuss/message/reaction");

      final body = jsonEncode({
        "jsonrpc": "2.0",
        "params": {
          "message_id": messageId,
          "content": content,
          "action": action,
        },
      });

      final res = await http.post(url, headers: _headers, body: body);

      if (res.statusCode != 200) {
        error = "Failed (${res.statusCode})";
        return null;
      }

      final decoded = jsonDecode(res.body);


      final payload = decoded is Map<String, dynamic>
          ? (decoded["result"] is Map<String, dynamic>
          ? decoded["result"] as Map<String, dynamic>
          : decoded)
          : null;

      if (payload == null) {
        error = "Invalid server response";
        return null;
      }

      final rr = ReactionResponse.fromJson(payload);

      if (!rr.success) {
        error = "Server returned success=false";
        return null;
      }

      return rr;
    } catch (e) {
      error = "Reaction error: $e";
      return null;
    }
  }
}
