import 'package:flutter/material.dart';
import 'package:mathsense/setting.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'addition.dart';
import 'subtraction.dart';
import 'multiplication.dart'; // Ensure you import the Multiplication page
import 'division.dart'; // Ensure you import the Division page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _speechEnabled = false;
  bool _isSpeaking = true; // Flag to disable button while speaking
  String _wordsSpoken = "";
  bool _aboutPageOpened = false; // Flag to prevent multiple navigations

  @override
  void initState() {
    super.initState();
    initSpeech();
    _speakInitialMessage();
  }

  @override
  void dispose() {
    _stopListening(); // Ensure the microphone stops listening when the widget is disposed
    _flutterTts.stop(); // Ensure TTS stops when the widget is disposed
    super.dispose();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  Future<void> _speakInitialMessage() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts
        .speak("Tap on the screen and say what skill you want to practice "
            "like addition, subtraction, multiplication, or division.");
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false; // Enable the button after speaking is done
      });
    });
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
          _aboutPageOpened = true;
          _stopListening();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdditionPage()),
          ).then((_) {
            _aboutPageOpened = false;
          });
        } else if (_wordsSpoken.toLowerCase().contains("subtraction")) {
          _aboutPageOpened = true;
          _stopListening();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SubtractionApp()),
          ).then((_) {
            _aboutPageOpened = false;
          });
        } else if (_wordsSpoken.toLowerCase().contains("multiplication")) {
          _aboutPageOpened = true;
          _stopListening();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MultiplicationApp()),
          ).then((_) {
            _aboutPageOpened = false;
          });
        } else if (_wordsSpoken.toLowerCase().contains("division")) {
          _aboutPageOpened = true;
          _stopListening();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DivisionApp()),
          ).then((_) {
            _aboutPageOpened = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // title: Text("Home Page"),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.settings,
        //       color: Colors.black,
        //     ),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => SettingsPage()),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: SafeArea(
        top: true,
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _isSpeaking
                        ? null // Disable the button while TTS is speaking
                        : _speechToText.isListening
                            ? _stopListening
                            : _startListening,
                    child: Text(
                      _speechToText.isListening
                          ? "Stop Listening"
                          : "Tap to Choose Quiz",
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSpeaking
                          ? Colors.grey
                          : Colors.white, // Grey out button while speaking
                      side: BorderSide(width: 2, color: Colors.black),
                      minimumSize: Size(double.infinity, 200),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Set the radius to 2
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _isSpeaking
                      ? null // Disable the button while TTS is speaking
                      : _speakInitialMessage,
                  child: Text(
                    "Repeat Instructions",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: BorderSide(width: 2, color: Colors.white),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              // Add Skip Instructions button here
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await _flutterTts.stop(); // Stop TTS immediately
                    setState(() {
                      _isSpeaking = false; // Allow other actions
                    });
                  },
                  child: Text(
                    "Skip Instructions",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: BorderSide(width: 2, color: Colors.white),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
