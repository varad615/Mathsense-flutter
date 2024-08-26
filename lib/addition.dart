import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(AdditionApp());
}

class AdditionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Addition Solver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AdditionPage(),
    );
  }
}

class AdditionPage extends StatefulWidget {
  @override
  _AdditionPageState createState() => _AdditionPageState();
}

class _AdditionPageState extends State<AdditionPage> {
  late stt.SpeechToText _speech;
  FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _text = "";
  MathQuestion? _currentQuestion;
  bool _processingAnswer = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _welcomeMessage();
  }

  void _welcomeMessage() async {
    _speak("Welcome to Addition Solver! Let's start with addition.");
    _generateNewQuestion(shouldSpeak: false); // Generate the first question without speaking it
  }

  void _generateNewQuestion({bool shouldSpeak = true}) {
    setState(() {
      _currentQuestion = generateAdditionQuestion();
      _text = ""; // Clear previous answer text
      _processingAnswer = false; // Reset answer processing flag
    });

    if (shouldSpeak) {
      _speak(_currentQuestion.toString());
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          if (val.hasConfidenceRating && val.confidence > 0.75 && !_processingAnswer) {
            setState(() {
              _text = val.recognizedWords;
              _checkAnswer(int.tryParse(_text) ?? 0);
            });
          }
        },
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 5),
        cancelOnError: true,
        partialResults: false,
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void _checkAnswer(int userAnswer) async {
    _processingAnswer = true;
    _stopListening();

    if (userAnswer == _currentQuestion?.answer) {
      _speak("Correct!");
      _generateNewQuestion(shouldSpeak: false);
    } else {
      _speak("Wrong, the right answer is ${_currentQuestion?.answer}.");
      _generateNewQuestion(shouldSpeak: false);
    }
  }

  void _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Addition Solver')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (_currentQuestion != null) {
                _speak(_currentQuestion.toString());
              }
            },
            child: Text(
              _currentQuestion?.toString() ?? "Tap to hear the question...",
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            onPressed: _isListening ? _stopListening : _startListening,
            child: Icon(_isListening ? Icons.mic_off : Icons.mic),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _generateNewQuestion(shouldSpeak: false),
            child: Text("Next Question"),
          ),
        ],
      ),
    );
  }
}

class MathQuestion {
  final int num1;
  final int num2;
  final String operation;
  final int answer;

  MathQuestion(this.num1, this.num2, this.operation, this.answer);

  @override
  String toString() {
    return "$num1 $operation $num2";
  }
}

MathQuestion generateAdditionQuestion() {
  Random random = Random();
  int num1 = random.nextInt(20) + 1;  // Random number between 1 and 20
  int num2 = random.nextInt(20) + 1;
  int answer = num1 + num2;

  return MathQuestion(num1, num2, "+", answer);
}
