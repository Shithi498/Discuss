import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import '../provider/auth_provider.dart';
import 'inbox_page.dart';
import 'login_screen.dart';

class PostLoginSplash extends StatefulWidget {
  const PostLoginSplash({super.key});

  @override
  State<PostLoginSplash> createState() => _PostLoginSplashState();
}

class _PostLoginSplashState extends State<PostLoginSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  bool _autoLoggingIn = true;
  static const _cookieKey = 'sessionCookie';
  // @override
  // void initState() {
  //   super.initState();
  //
  //   _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  //   _fade = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  //
  //   _scale = Tween<double>(begin: 0.85, end: 1.05).animate(
  //     CurvedAnimation(parent: _c, curve: Curves.elasticInOut
  //     ),
  //   );
  //
  //   _c.repeat(reverse: true);
  //  // _c.forward();
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     Future.delayed(const Duration(milliseconds: 2500), () {
  //       if (!mounted) return;
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (_) => const LoginScreen()),
  //       );
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();

    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(parent: _c, curve: Curves.elasticInOut),
    );
    _c.repeat(reverse: true);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //        Future.delayed(const Duration(milliseconds: 2500), () {
    //          if (!mounted) return;Navigator.of(context).pushReplacement(
    //            MaterialPageRoute(builder: (_) => const LoginScreen()),
    //          );
    //        });
    //      });
    _tryAutoLogin();
  }



  Future<void> _tryAutoLogin() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final savedCookie = prefs.getString(_cookieKey);


      if (savedCookie == null || savedCookie.isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

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

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final result = decoded['result'];

      final uid = (result is Map<String, dynamic>) ? result['uid'] : null;
      final loggedIn = !(uid == null || uid == false || uid == 0);


      if (!loggedIn) {
        await prefs.remove(_cookieKey);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }


      if (result is Map<String, dynamic>) {
        final u = ChatUser.fromOdooSession(result, sessionCookie: savedCookie);
        auth.user = u;
        auth.sessionCookie = savedCookie;
        auth.notifyListeners();
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const InboxPage()),
      );
    } catch (_) {


    } finally {
      if (mounted) setState(() => _autoLoggingIn = false);
    }
  }


  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
               children:  [
                 Image.asset(
                   "assets/images/images.png",
                   gaplessPlayback: true,
                   filterQuality: FilterQuality.low,
                 ),



                 SizedBox(height: 14),

              ],
            ),
          ),
        ),
      ),
    );
  }
}



