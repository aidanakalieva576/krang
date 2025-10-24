import 'package:flutter/material.dart';

class OnboardPageSecond extends StatefulWidget {
  const OnboardPageSecond({super.key});

  @override
  State<OnboardPageSecond> createState() => _OnboardPageSecondState();
}

class _OnboardPageSecondState extends State<OnboardPageSecond> {
  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF1A1A1A);
    const headlineColour = Color(0xFFE6E6E6);
    const subtitleColour = Color(0xFF9A9A9A);
    // const pillBackground = Color(0xFFEFEFEF);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
          child: Column(
            children: [
              SizedBox(
                height: 130,
                child: Center(
                  child: Image.asset('assets/icons_user/logo.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 20),
              const Spacer(flex: 2),
              const Text(
                'Your personal\n cinema',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: headlineColour,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Watch anywhere, anytime. Save favorites, continue where you left off, and let our smart system suggest what to watch next.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subtitleColour,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: 160,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
