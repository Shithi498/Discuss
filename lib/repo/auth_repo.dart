import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

// class OdooAuthRepo {
//   final String baseUrl;
//   String? sessionCookie;
//
//   OdooAuthRepo({required this.baseUrl});
//
//
//
//   Future<ChatUser> login({
//     required String db,
//     required String login,
//     required String password,
//   }) async {
//     final uri = Uri.parse('$baseUrl/web/session/authenticate');
//
//     final payload = {
//       "jsonrpc": "2.0",
//       "params": {
//         "db": db,
//         "login": login,
//         "password": password,
//       }
//     };
//
//     final res = await http.post(
//       uri,
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//       body: jsonEncode(payload),
//     );
//
// print("res");
//     print(res.body);
// print(res.statusCode);
//     if (res.statusCode != 200) {
//       throw Exception('HTTP ${res.statusCode}: ${res.body}');
//     }
//
//     final decoded = jsonDecode(res.body) as Map<String, dynamic>;
//
//     if (decoded['error'] != null) {
//       final err = decoded['error'] as Map<String, dynamic>;
//       final msg = (err['message'] ?? '').toString();
//       throw Exception('Odoo auth error: $msg');
//     }
//
//     final result = decoded['result'] as Map<String, dynamic>;
//
//
//     String? sessionCookie;
//     final setCookie = res.headers['set-cookie'];
//     if (setCookie != null) {
//
//       final parts = setCookie.split(',');
//
//       for (final p in parts) {
//         final trimmed = p.trim();
//         if (trimmed.startsWith('session_id=')) {
//           sessionCookie = trimmed.split(';').first;
//           break;
//         }
//       }
//     }
//
//     return ChatUser.fromOdooSession(
//       result,
//       sessionCookie: sessionCookie,
//     );
//
//     if (sessionCookie != null) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('sessionCookie', sessionCookie);
//     }
//
//   }
//
//
//
//
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OdooAuthRepo {
  final String baseUrl;
  String? sessionCookie;

  OdooAuthRepo({required this.baseUrl});

  static const _cookieKey = 'sessionCookie';

  Future<void> saveSessionCookie(String cookie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookieKey, cookie);
    sessionCookie = cookie;
  }

  Future<String?> loadSessionCookie() async {
    final prefs = await SharedPreferences.getInstance();
    sessionCookie = prefs.getString(_cookieKey);
    return sessionCookie;
  }

  Future<void> clearSessionCookie() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
    sessionCookie = null;
  }

  String? _extractSessionCookieFromHeaders(http.Response res) {
    final setCookie = res.headers['set-cookie'];
    if (setCookie == null) return null;

    final parts = setCookie.split(',');
    for (final p in parts) {
      final trimmed = p.trim();
      if (trimmed.startsWith('session_id=')) {
        return trimmed.split(';').first;
      }
    }
    return null;
  }

  Future<ChatUser> login({
    required String db,
    required String login,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/web/session/authenticate');

    final payload = {
      "jsonrpc": "2.0",
      "params": {"db": db, "login": login, "password": password}
    };

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

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
    final cookie = _extractSessionCookieFromHeaders(res);

    if (cookie != null) {
      await saveSessionCookie(cookie); // ✅ persist immediately
    }

    return ChatUser.fromOdooSession(result, sessionCookie: cookie);
  }


  Future<ChatUser> getSessionInfo({required String db}) async {
    final uri = Uri.parse('$baseUrl/web/session/get_session_info');

    final payload = {
      "jsonrpc": "2.0",
      "params": {}
    };

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionCookie != null) 'Cookie': sessionCookie!,
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (decoded['error'] != null) {
      throw Exception('Session invalid');
    }

    final result = decoded['result'] as Map<String, dynamic>;

    // If session is not logged in, uid is usually false / null / 0.
    final uid = result['uid'];
    if (uid == null || uid == false || uid == 0) {
      throw Exception('Session invalid');
    }


    result['db'] ??= db;

    return ChatUser.fromOdooSession(result, sessionCookie: sessionCookie);
  }
}




