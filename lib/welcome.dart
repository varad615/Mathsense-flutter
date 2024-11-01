import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mathsense/home_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _speakWelcomeMessage();
  }

  Future<void> _speakWelcomeMessage() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(
        "Hi, this is Math Sense, a math application for the visually impaired developed by Ishaan. "
        "Tap on the screen to start the quiz ");
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen height
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        // Navigate to the homepage when the screen is tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Center the image
              Center(
                child: Image.asset(
                  'assets/images/logo2.png', // Update with your image path
                  height: screenHeight *
                      0.5, // Set height as 50% of the screen height
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16.0), // Space between the image and the text
              const Text(
                'By Ishaan Bhasin',
                style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
