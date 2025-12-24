import 'package:flutter/cupertino.dart';

import '../model/user_model.dart';
import '../repo/auth_repo.dart';

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
    _error = null;
    notifyListeners();
    final u = await repo.login(
      db: db,
      login: login,
      password: password,
    );
    user = u;

    sessionCookie = u.sessionCookie;
    notifyListeners();
  }

  void logout() {
    user = null;
    _error = null;
    notifyListeners();
  }
}