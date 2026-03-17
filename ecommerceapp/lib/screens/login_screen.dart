import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/cubits/auth/auth_cubit.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  final String? selectedGender;

  const LoginScreen({super.key, this.selectedGender});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    final data = await context.read<AuthCubit>().loadRememberedUser();
    setState(() {
      _email.text = data['email'];
      _password.text = data['password'];
      _rememberMe = data['remember'];
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        _email.text.trim(),
        _password.text.trim(),
        remember: _rememberMe,
      );
      if (!_rememberMe) {
        context.read<AuthCubit>().clearRememberedUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      "Welcome",
                      style: GoogleFonts.cairo(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please enter your data to continue",
                      style: GoogleFonts.cairo(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 60),

                    TextFormField(
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        suffixIcon: isValidEmail(_email.text)
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) =>
                          !isValidEmail(v ?? "") ? "Invalid email" : null,
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: _password.text.length >= 6
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) =>
                          v!.length < 6 ? "Password too short" : null,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Don’t have an account?",
                              style: GoogleFonts.cairo(),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegisterScreen(
                                      selectedGender:
                                          widget.selectedGender ??
                                          "Unspecified",
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.cairo(
                                  color: const Color(0xFF9775FA),
                                ),
                              ),
                            ),
                          ],
                        ),

                        TextButton(
                          onPressed: () async {
                            if (isValidEmail(_email.text)) {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(
                                    email: _email.text.trim(),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password reset email sent successfully",
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Enter a valid email first"),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Forget password?",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),

                    SwitchListTile(
                      title: const Text("Remember me"),
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v),
                      activeTrackColor: Colors.green,
                      activeColor: Colors.white,
                    ),

                    const SizedBox(height: 180),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Text.rich(
                        TextSpan(
                          text:
                              "By connecting your account confirm that you agree with our ",
                          style: GoogleFonts.cairo(
                            fontSize: 14.3,
                            color: Colors.grey[700],
                          ),
                          children: [
                            TextSpan(
                              text: "Term and Condition",
                              style: GoogleFonts.cairo(
                                color: const Color.fromARGB(255, 41, 41, 41),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: 70,
            child: ElevatedButton(
              onPressed: loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9775FA),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Login",
                      style: GoogleFonts.cairo(
                        fontSize: 19,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
