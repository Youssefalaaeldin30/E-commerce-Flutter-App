import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/cubits/onboard/onboarding_cubit.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingSelected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LoginScreen(selectedGender: state.gender),
            ),
          );
        } else if (state is OnboardingSkipped) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      builder: (context, state) {
        return const _OnboardingBody();
      },
    );
  }
}

class _OnboardingBody extends StatefulWidget {
  const _OnboardingBody();

  @override
  State<_OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends State<_OnboardingBody> {
  String selected = "Women";

  void _onOptionSelected(String gender) {
    setState(() => selected = gender);
    context.read<OnboardingCubit>().selectGender(gender);
  }

  void _onSkip() => context.read<OnboardingCubit>().skip();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: Stack(
        children: [
          _buildFancyBackground(),
          Positioned(
            top: height * 0.1,
            left: width * 0.05,
            right: width * 0.05,
            child: Image.asset(
              "assets/images/model.png",
              height: height * 0.75,
              fit: BoxFit.contain,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: height * 0.02),
              child: Container(
                width: width * 0.9,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.03,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Look Good, Feel Good",
                      style: TextStyle(
                        fontSize: height * 0.028,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    Text(
                      "Create your individual & unique style and look amazing everyday.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: height * 0.018,
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                    Row(
                      children: [
                        _buildOptionButton("Men", width, height),
                        SizedBox(width: width * 0.04),
                        _buildOptionButton("Women", width, height),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    TextButton(
                      onPressed: _onSkip,
                      child: const Text(
                        "Skip",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String label, double width, double height) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onOptionSelected(label),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: height * 0.02),
          decoration: BoxDecoration(
            color: selected == label
                ? const Color(0xFF9775FA)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected == label ? Colors.white : Colors.black,
                fontSize: height * 0.02,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFancyBackground() {
    return Stack(
      children: [
        Container(color: const Color(0xFF9775FA)),
        Positioned(top: -80, left: -60, child: _sunShape(250)),
        Positioned(top: 280, left: -80, child: _sunShape(180)),
        Positioned(bottom: 150, right: -60, child: _sunShape(220)),
      ],
    );
  }

  Widget _sunShape(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color.fromARGB(115, 255, 255, 255),
            Color.fromARGB(0, 255, 255, 255),
          ],
          stops: [0, 1],
        ),
      ),
    );
  }
}
