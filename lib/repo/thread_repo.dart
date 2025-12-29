import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/thread_model.dart';

class ThreadRepo {
  final String baseUrl;
  final String sessionCookie;

  ThreadRepo({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Cookie": sessionCookie,
  };

  Future<List<MessageThread>> fetchThreads() async {

    if (sessionCookie.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse("$baseUrl/api/discuss/channels");


    final body = jsonEncode({
      "jsonrpc": "2.0",
      "params": {
        "thread_type": "chat",
      },
    });

    final response = await http.post(
      url,
      headers: _headers,
      body: body,
    );
    print("Thread");
print(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load threads. Status: ${response.statusCode}. Body: ${response.body}",
      );
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    final Map<String, dynamic> root = decoded['result'] is Map<String, dynamic>
        ? decoded['result'] as Map<String, dynamic>
        : decoded;

    final List<dynamic> threadsJson =
        root['threads'] as List<dynamic>? ?? [];

    return threadsJson
        .map((t) => MessageThread.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageThread>> groupfetchThreads() async {

    if (sessionCookie.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse("$baseUrl/api/discuss/channels");


    final body = jsonEncode({
      "jsonrpc": "2.0",
      "params": {
        "thread_type": "group",
      },
    });

    final response = await http.post(
      url,
      headers: _headers,
      body: body,
    );
    print("group thread");
    print(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load threads. Status: ${response.statusCode}. Body: ${response.body}",
      );
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    final Map<String, dynamic> root = decoded['result'] is Map<String, dynamic>
        ? decoded['result'] as Map<String, dynamic>
        : decoded;

    final List<dynamic> threadsJson =
        root['threads'] as List<dynamic>? ?? [];

    return threadsJson
        .map((t) => MessageThread.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageThread>> channelfetchThreads() async {

    if (sessionCookie.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse("$baseUrl/api/discuss/channels");


    final body = jsonEncode({
      "jsonrpc": "2.0",
      "params": {
        "thread_type": "channel",
      },
    });

    final response = await http.post(
      url,
      headers: _headers,
      body: body,
    );
    print("channel thread");
    print(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load threads. Status: ${response.statusCode}. Body: ${response.body}",
      );
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    final Map<String, dynamic> root = decoded['result'] is Map<String, dynamic>
        ? decoded['result'] as Map<String, dynamic>
        : decoded;

    final List<dynamic> threadsJson =
        root['threads'] as List<dynamic>? ?? [];

    return threadsJson
        .map((t) => MessageThread.fromJson(t as Map<String, dynamic>))
        .toList();
  }
}
