import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import '../provider/auth_provider.dart';
import 'inbox_page.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();


  bool _rememberMe = false;
  bool _autoLoggingIn = true;
  static const _cookieKey = 'sessionCookie';
  bool _didNavigate = false;
  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
  // Future<void> _tryAutoLogin() async {
  //   try {
  //    // await Future.delayed(const Duration(milliseconds: 1000));
  //     final prefs = await SharedPreferences.getInstance();
  //     final savedCookie = prefs.getString(_cookieKey);
  //
  //     if (savedCookie == null || savedCookie.isEmpty) {
  //       return;
  //     }
  //
  //     final auth = context.read<AuthProvider>();
  //
  //
  //     final uri = Uri.parse('${auth.repo.baseUrl}/web/session/get_session_info');
  //     final payload = {"jsonrpc": "2.0", "params": {}};
  //
  //     final res = await http.post(
  //       uri,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Cookie': savedCookie,
  //       },
  //       body: jsonEncode(payload),
  //     );
  //
  //     if (res.statusCode != 200) {
  //
  //       await prefs.remove(_cookieKey);
  //       return;
  //     }
  //
  //     final decoded = jsonDecode(res.body) as Map<String, dynamic>;
  //     final result = decoded['result'];
  //
  //
  //     final uid = (result is Map<String, dynamic>) ? result['uid'] : null;
  //     final loggedIn = !(uid == null || uid == false || uid == 0);
  //
  //     if (!loggedIn) {
  //       await prefs.remove(_cookieKey);
  //       return;
  //     }
  //
  //
  //     if (result is Map<String, dynamic>) {
  //       final u = ChatUser.fromOdooSession(result, sessionCookie: savedCookie);
  //       auth.user = u;
  //       auth.sessionCookie = savedCookie;
  //
  //       auth.notifyListeners();
  //     }
  //
  //     if (!mounted) return;
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (_) => const InboxPage()),
  //     );
  //   } catch (_) {
  //
  //   } finally {
  //    // if (mounted) setState(() => _autoLoggingIn = false);
  //   }
  // }


  Future<void> _tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCookie = prefs.getString(_cookieKey);

      if (savedCookie == null || savedCookie.isEmpty) return;

      final auth = context.read<AuthProvider>();
      final uri = Uri.parse('${auth.repo.baseUrl}/web/session/get_session_info');
      final payload = {"jsonrpc": "2.0", "params": {}};

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cookie': savedCookie,
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode != 200) {
        await prefs.remove(_cookieKey);
        return;
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final result = decoded['result'];

      final uid = (result is Map<String, dynamic>) ? result['uid'] : null;
      final loggedIn = !(uid == null || uid == false || uid == 0);

      if (!loggedIn) {
        await prefs.remove(_cookieKey);
        return;
      }

      if (result is Map<String, dynamic>) {
        final u = ChatUser.fromOdooSession(result, sessionCookie: savedCookie);
        auth.user = u;
        auth.sessionCookie = savedCookie;
        auth.notifyListeners();
      }

      if (!mounted) return;

      _didNavigate = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const InboxPage()),
      );
    } catch (_) {

    } finally {

      if (mounted && !_didNavigate) {
        setState(() => _autoLoggingIn = false);
      }
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    await auth.login(
      db: 'odoo4',
      login: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    if (!mounted) return;

    if (auth.user != null && auth.error == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const InboxPage()),
      );
    } else {
      setState(() {});
    }
  }



  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    const bgBlue = Color(0xFF1F6FC1);
    const accentYellow = Color(0xFFF4B400);
    const buttonGreen = Color(0xFF6D8F7A);
     const orangeGradient =  Color(0xFFF45A1D);

    if (_autoLoggingIn) {
      return Scaffold(

        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const SizedBox(height: 16),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
            ),
          ),
        ),
      );
    }else {
      return Scaffold(
        backgroundColor: bgBlue,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = MediaQuery
                  .of(context)
                  .size
                  .width;
              final h = constraints.maxHeight;

              final cardWidth = math.min(w * 0.86, 380.0);
              final cardPadding = (w * 0.045).clamp(14.0, 20.0);
              final headerHeight = (h * 0.20).clamp(95.0, 140.0);
              final logoSize = (headerHeight * 0.70).clamp(60.0, 100.0);

              return Stack(
                children: [

                  SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,

                      bottom: MediaQuery
                          .of(context)
                          .viewInsets
                          .bottom + 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: h),
                      child: Center(
                        child: Container(
                          width: cardWidth,
                          padding: EdgeInsets.all(cardPadding),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 30,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: SizedBox(
                                    height: headerHeight,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white.withOpacity(
                                                      0.06),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Image.asset(
                                            "assets/images/images.png",
                                            width: logoSize,
                                            height: logoSize,
                                            fit: BoxFit.contain,
                                            gaplessPlayback: true,
                                            filterQuality: FilterQuality.low,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: (h * 0.02).clamp(8.0, 14.0)),

                                _UnderlinedField(
                                  label: 'Email Address',
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) =>
                                  (v == null || v.isEmpty)
                                      ? 'Enter login/email'
                                      : null,
                                ),

                                SizedBox(height: (h * 0.025).clamp(10.0, 16.0)),

                                _UnderlinedField(
                                  label: 'Password',
                                  controller: _passwordCtrl,
                                  obscureText: true,
                                  validator: (v) =>
                                  (v == null || v.length < 3)
                                      ? 'Enter a valid password'
                                      : null,
                                ),

                                SizedBox(height: (h * 0.02).clamp(8.0, 12.0)),

                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (v) =>
                                          setState(() =>
                                          _rememberMe = v ?? false),
                                      materialTapTargetSize: MaterialTapTargetSize
                                          .shrinkWrap,
                                    ),
                                    const Text('Remember me',
                                        style: TextStyle(fontSize: 13)),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(10, 10),
                                        tapTargetSize: MaterialTapTargetSize
                                            .shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),

                                if (auth.error != null) ...[
                                  const SizedBox(height: 6),
                                  Text(auth.error!, style: const TextStyle(
                                      color: Colors.red)),
                                ],

                                SizedBox(height: (h * 0.02).clamp(8.0, 12.0)),

                                SizedBox(
                                  height: (h * 0.07).clamp(46.0, 56.0),
                                  child: auth.loading
                                      ? const Center(
                                      child: CircularProgressIndicator())
                                      : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: orangeGradient,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w700,
                                        color: bgBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 8,
                    top: 8,
                    child: IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }
  }
}

class _UnderlinedField extends StatelessWidget {
  const _UnderlinedField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
            border: const UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFF4B400), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}





