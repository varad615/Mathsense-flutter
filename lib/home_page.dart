import 'package:flutter/material.dart';
import 'package:mathsense/setting.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'addition.dart';
import 'subtraction.dart';
import 'multiplication.dart';
import 'division.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _speechEnabled = false;
  bool _isSpeaking = true;
  String _wordsSpoken = "";
  bool _aboutPageOpened = false;

  @override
  void initState() {
    super.initState();
    initSpeech();
    _speakInitialMessage(); // Speak initial message on page load
  }

  @override
  void dispose() {
    _stopListening();
    _flutterTts.stop();
    super.dispose();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  Future<void> _speakInitialMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double speechRate = prefs.getDouble('speechRate') ?? 0.5; // Fetch rate or use default 0.5

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(speechRate); // Use stored or default rate
    await _flutterTts.speak(
      "Tap on the screen and say what skill you want to practice "
      "like addition, subtraction, multiplication, or division.",
    );
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  void _startListening() async {
    _aboutPageOpened = false;
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
          _navigateToPage(AdditionPage());
        } else if (_wordsSpoken.toLowerCase().contains("subtraction")) {
          _navigateToPage(SubtractionApp());
        } else if (_wordsSpoken.toLowerCase().contains("multiplication")) {
          _navigateToPage(MultiplicationApp());
        } else if (_wordsSpoken.toLowerCase().contains("division")) {
          _navigateToPage(DivisionApp());
        }
      }
    });
  }

  void _navigateToPage(Widget page) {
    _aboutPageOpened = true;
    _stopListening();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      _aboutPageOpened = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _isSpeaking
                        ? null
                        : _speechToText.isListening
                            ? _stopListening
                            : _startListening,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isSpeaking ? Colors.grey : Colors.white,
                      side: const BorderSide(width: 2, color: Colors.black),
                      minimumSize: const Size(double.infinity, 200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _speechToText.isListening
                          ? "Stop Listening"
                          : "Tap to Choose Quiz",
                      style: const TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _isSpeaking ? null : _speakInitialMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(width: 2, color: Colors.white),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Repeat Instructions",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await _flutterTts.stop();
                    setState(() {
                      _isSpeaking = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(width: 2, color: Colors.white),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Skip Instructions",
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}
