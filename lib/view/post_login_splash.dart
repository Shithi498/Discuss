import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeInOut);

    _scale = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(parent: _c, curve: Curves.elasticInOut
      ),
    );

    _c.repeat(reverse: true);
   // _c.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    });
  }


  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
               children:  [
                 Image.asset(
                   "assets/images/images.jpg",
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


