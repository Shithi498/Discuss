import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import '../repo/auth_repo.dart';

// class AuthProvider extends ChangeNotifier {
//   final OdooAuthRepo repo;
//   String? sessionCookie;
//   AuthProvider({required this.repo});
//
//   ChatUser? user;
//
//
//   bool _loading = false;
//   bool get loading => _loading;
//
//   String? _error;
//   String? get error => _error;
//
//   bool get isLoggedIn => user != null;
//
//
//
//   Future<void> login({
//     required String db,
//     required String login,
//     required String password,
//   }) async {
//     _error = null;
//     notifyListeners();
//     final u = await repo.login(
//       db: db,
//       login: login,
//       password: password,
//     );
//     user = u;
//
//     sessionCookie = u.sessionCookie;
//     notifyListeners();
//   }
//
//   void logout() {
//     user = null;
//     _error = null;
//     notifyListeners();
//   }
// }

import 'package:flutter/foundation.dart';

import '../view/login_screen.dart';

class AuthProvider extends ChangeNotifier {
  final OdooAuthRepo repo;
  String? sessionCookie;

  AuthProvider({required this.repo});

  ChatUser? user;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  bool get isLoggedIn => user != null;

  Future<void> login({
    required String db,
    required String login,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final u = await repo.login(db: db, login: login, password: password);
      user = u;
      sessionCookie = u.sessionCookie;
    } catch (e) {
      _error = e.toString();
      user = null;
      sessionCookie = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }


  Future<void> tryAutoLogin({required String db}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final cookie = await repo.loadSessionCookie();
      if (cookie == null) {
        user = null;
        return;
      }

      sessionCookie = cookie;

      // Validate cookie with Odoo
      final u = await repo.getSessionInfo(db: db);
      user = u;
    } catch (e) {
      // Cookie invalid/expired -> clear it
      await repo.clearSessionCookie();
      user = null;
      sessionCookie = null;
      _error = null; // keep UI clean; optional: store e.toString()
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    _loading = true;
    notifyListeners();

    try {

      sessionCookie = null;
      user = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );

    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}


