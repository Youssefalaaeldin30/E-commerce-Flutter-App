import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '/cubits/auth/auth_cubit.dart';
import 'home_screen.dart';
import '/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  final String? selectedGender;
  const RegisterScreen({super.key, this.selectedGender});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool remember = false;

  void _onRegister() async {
    if (_formKey.currentState!.validate()) {
      await context.read<AuthCubit>().register(
        _email.text.trim(),
        _password.text.trim(),
        _name.text.trim(),
        gender: widget.selectedGender,
        remember: remember,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Sign Up",
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 60),

                    TextFormField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: "Username",
                        suffixIcon: _name.text.isNotEmpty
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) =>
                          v!.isEmpty ? "Please enter your name" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: _password.text.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Center(
                                  widthFactor: 1,
                                  child: Text(
                                    getPasswordStrength(_password.text),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: getStrengthColor(
                                        getPasswordStrength(_password.text),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                      ),
                      validator: (v) => v!.length < 6
                          ? "Password must be at least 6 chars"
                          : null,
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 30),

                    SwitchListTile(
                      title: const Text("Remember me"),
                      value: remember,
                      onChanged: (v) => setState(() => remember = v),
                      activeTrackColor: Colors.green,
                      activeColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: 70,
            child: ElevatedButton(
              onPressed: loading ? null : _onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9775FA),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Sign Up",
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
