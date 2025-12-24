import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/user_model.dart';

class OdooAuthRepo {
  final String baseUrl;


  OdooAuthRepo({required this.baseUrl});

  Future<ChatUser> login({
    required String db,
    required String login,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/web/session/authenticate');

    final payload = {
      "jsonrpc": "2.0",
      "params": {
        "db": db,
        "login": login,
        "password": password,
      }
    };

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

print("res");
    print(res.body);
print(res.statusCode);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    if (decoded['error'] != null) {
      final err = decoded['error'] as Map<String, dynamic>;
      final msg = (err['message'] ?? '').toString();
      throw Exception('Odoo auth error: $msg');
    }

    final result = decoded['result'] as Map<String, dynamic>;


    String? sessionCookie;
    final setCookie = res.headers['set-cookie'];
    if (setCookie != null) {

      final parts = setCookie.split(',');

      for (final p in parts) {
        final trimmed = p.trim();
        if (trimmed.startsWith('session_id=')) {
          sessionCookie = trimmed.split(';').first;
          break;
        }
      }
    }

    return ChatUser.fromOdooSession(
      result,
      sessionCookie: sessionCookie,
    );
  }
}
