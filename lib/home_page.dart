import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'addition.dart';
import 'subtraction.dart'; // Ensure you import the Subtraction page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _wordsSpoken = "";
  bool _aboutPageOpened = false; // Flag to prevent multiple navigations

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  @override
  void dispose() {
    _stopListening(); // Ensure the microphone stops listening when the widget is disposed
    super.dispose();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    _aboutPageOpened = false; // Reset the flag when listening starts
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      if (!_aboutPageOpened) {
        if (_wordsSpoken.toLowerCase().contains("addition")) {
          _aboutPageOpened =
              true; // Set the flag to true to prevent multiple navigations
          _stopListening();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Addition()),
          ).then((_) {
            _aboutPageOpened =
                false; // Reset the flag when returning from the about page
          });
        } else if (_wordsSpoken.toLowerCase().contains("subtraction")) {
          _aboutPageOpened =
              true; // Set the flag to true to prevent multiple navigations
          _stopListening();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Subtraction()),
          ).then((_) {
            _aboutPageOpened =
                false; // Reset the flag when returning from the about page
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Mathsense',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _speechToText.isListening
                      ? _stopListening
                      : _startListening,
                  child: Text(
                    _speechToText.isListening
                        ? "Stop Listening"
                        : "Tap to Start Listening",
                    style: TextStyle(fontSize: 24, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(width: 5, color: Colors.black),
                    minimumSize: Size(double.infinity, 200),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Set the radius to 2
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   Navigator.push(
      //       context, MaterialPageRoute(builder: (context) => Subtraction()));
      // }),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
