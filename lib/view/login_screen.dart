import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    await auth.login(
      db: 'test',
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


    return Scaffold(
      backgroundColor: bgBlue,
      body: SafeArea(
        child: Stack(
          children: [

            Center(

                child: Container(
                  width: math.min(MediaQuery.of(context).size.width * 0.86, 380),
                  padding: const EdgeInsets.all(18),
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
                            child: Container(
                              height: 170,
                              color: Colors.white,
                              child: Stack(
                                children: [

                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withOpacity(0.06),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [

                                        Image.asset(
                                          "assets/images/images.jpg",
                                            width: 100,
                                              height: 100,
                                          gaplessPlayback: true,
                                          filterQuality: FilterQuality.low,
                                        ),
                                        const SizedBox(height: 10),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Email (underline style)
                          _UnderlinedField(
                            label: 'Email Address',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                            (v == null || v.isEmpty) ? 'Enter login/email' : null,
                          ),

                          const SizedBox(height: 14),

                          // Password (underline style)
                          _UnderlinedField(
                            label: 'Password',
                            controller: _passwordCtrl,
                            obscureText: true,
                            validator: (v) =>
                            (v == null || v.length < 3) ? 'Enter a valid password' : null,
                          ),

                          const SizedBox(height: 10),

                          // Remember me + Forgot
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(fontSize: 13),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  // TODO: hook your forgot password action
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(10, 10),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          if (auth.error != null) ...[
                            Text(
                              auth.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Login button
                          SizedBox(
                            height: 52,
                            child: auth.loading
                                ? const Center(child: CircularProgressIndicator())
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
                                  color:bgBlue
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Bottom text like mock (optional)
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     Text(
                          //       "Don't have an account? ",
                          //       style: TextStyle(
                          //         color: Colors.black.withOpacity(0.6),
                          //         fontSize: 12,
                          //       ),
                          //     ),
                          //     GestureDetector(
                          //       onTap: () {
                          //
                          //       },
                          //       child: const Text(
                          //         "SIGN UP",
                          //         style: TextStyle(
                          //           fontSize: 12,
                          //           fontWeight: FontWeight.w800,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),

                ),

            ),

            // (Optional) top back button area - remove if you don't want it
            Positioned(
              left: 8,
              top: 8,
              child: IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
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

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}


// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../provider/auth_provider.dart';
// import 'inbox_page.dart';
//
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailCtrl = TextEditingController();
//   final _passwordCtrl = TextEditingController();
//
//   bool _rememberMe = false;
//
//   @override
//   void dispose() {
//     _emailCtrl.dispose();
//     _passwordCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final auth = context.read<AuthProvider>();
//
//     await auth.login(
//       db: 'odoo2',
//       login: _emailCtrl.text.trim(),
//       password: _passwordCtrl.text.trim(),
//     );
//
//     if (!mounted) return;
//
//     if (auth.user != null && auth.error == null) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (_) => const InboxPage()),
//       );
//     } else {
//       setState(() {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = context.watch<AuthProvider>();
//     final size = MediaQuery.of(context).size;
//
//     const bg = Color(0xFFFFF3F6);        // light pink background
//     const blueLine = Color(0xFF1F6FC1);  // kendroo-ish blue for input lines
//     const orange1 = Color(0xFFF89A2E);
//     const orange2 = Color(0xFFF45A1D);
//
//     return Scaffold(
//       backgroundColor: bg,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // Close button top-right
//             Positioned(
//               right: 10,
//               top: 10,
//               child: InkWell(
//                 onTap: () => Navigator.maybePop(context),
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFFFD54F),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.close, size: 18, color: Colors.white),
//                 ),
//               ),
//             ),
//
//             // Main content
//             Center(
//               child: Container(
//                 width: math.min(size.width * 0.86, 360),
//                 height:500,
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(18),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // orange circle behind the image (top)
//                       SizedBox(
//                         height: 140,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//
//                             // your image/icon
//                             Image.asset(
//                               "assets/images/images.jpg",
//                               width: 200,
//                               height: 200,
//                               fit: BoxFit.contain,
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       // Email
//                       _UnderlinedField(
//                         hint: 'Email / Login',
//                         controller: _emailCtrl,
//                         underlineColor: blueLine,
//                         validator: (v) =>
//                         (v == null || v.isEmpty) ? 'Enter login/email' : null,
//                         prefixIcon: Icons.person,
//                       ),
//
//                       const SizedBox(height: 14),
//
//                       // Password
//                       _UnderlinedField(
//                         hint: 'Password',
//                         controller: _passwordCtrl,
//                         obscureText: true,
//                         underlineColor: blueLine,
//                         validator: (v) => (v == null || v.length < 3)
//                             ? 'Enter a valid password'
//                             : null,
//                         prefixIcon: Icons.lock,
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       // Error
//                       if (auth.error != null) ...[
//                         Text(
//                           auth.error!,
//                           style: const TextStyle(color: Colors.red, fontSize: 12),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 10),
//                       ],
//
//                       SizedBox(height: 30),
//                       SizedBox(
//                         height: 44,
//                         width: 160,
//                         child: auth.loading
//                             ? const Center(child: CircularProgressIndicator())
//                             : DecoratedBox(
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               begin: Alignment.centerLeft,
//                               end: Alignment.centerRight,
//                               colors: [orange1, orange2],
//                             ),
//                             borderRadius: BorderRadius.circular(22),
//                           ),
//                           child: ElevatedButton(
//                             onPressed: _login,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.transparent,
//                               shadowColor: Colors.transparent,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(22),
//                               ),
//                             ),
//                             child: const Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'GO',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w800,
//                                     letterSpacing: 1,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 SizedBox(width: 10),
//                                 Icon(Icons.arrow_forward,
//                                     color: Colors.white, size: 18),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 20),
//
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }
//
// class _UnderlinedField extends StatelessWidget {
//   const _UnderlinedField({
//     required this.hint,
//     required this.controller,
//     required this.underlineColor,
//     this.obscureText = false,
//     this.validator,
//     this.keyboardType,
//     this.prefixIcon,
//   });
//
//   final String hint;
//   final TextEditingController controller;
//   final Color underlineColor;
//   final bool obscureText;
//   final String? Function(String?)? validator;
//   final TextInputType? keyboardType;
//   final IconData? prefixIcon;
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       obscureText: obscureText,
//       validator: validator,
//       style: const TextStyle(fontSize: 14),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(color: Colors.black.withOpacity(0.35)),
//         prefixIcon: prefixIcon == null
//             ? null
//             : Icon(prefixIcon, size: 18, color: underlineColor),
//         isDense: true,
//         contentPadding: const EdgeInsets.symmetric(vertical: 10),
//         enabledBorder: UnderlineInputBorder(
//           borderSide: BorderSide(color: underlineColor, width: 1.2),
//         ),
//         focusedBorder: UnderlineInputBorder(
//           borderSide: BorderSide(color: underlineColor, width: 2),
//         ),
//       ),
//     );
//   }
// }
//
//
// class _Dot extends StatelessWidget {
//   const _Dot({required this.color, required this.size});
//   final Color color;
//   final double size;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//     );
//   }
// }

