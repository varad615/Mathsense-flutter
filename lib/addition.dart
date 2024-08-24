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
    _welcomeAndLoadQuestion();
  }

  void _welcomeAndLoadQuestion() async {
    _speak("Welcome to Addition Solver!");
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    setState(() {
      _currentQuestion = generateAdditionQuestion();
      _text = ""; // Clear previous answer text
      _processingAnswer = false; // Reset answer processing flag
    });
    _speak(_currentQuestion.toString());
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          if (val.hasConfidenceRating &&
              val.confidence > 0.75 &&
              !_processingAnswer) {
            setState(() {
              _text = val.recognizedWords;
              _checkAnswer(int.tryParse(_text) ?? 0);
            });
          }
        },
        listenFor: Duration(seconds: 10), // Listen for a longer duration
        pauseFor: Duration(seconds: 5), // Pause to allow user to respond
        cancelOnError: true,
        partialResults: false, // Only process final results
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void _checkAnswer(int userAnswer) async {
    _processingAnswer =
        true; // Prevent further processing until this is complete
    _stopListening(); // Stop listening during answer check

    if (userAnswer == _currentQuestion?.answer) {
      _speak("Correct!");
    } else {
      _speak("Incorrect, the correct answer is ${_currentQuestion?.answer}.");
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
          Text(
            _currentQuestion?.toString() ?? "Loading question...",
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            onPressed: _isListening ? _stopListening : _startListening,
            child: Icon(_isListening ? Icons.mic_off : Icons.mic),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _generateNewQuestion,
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
  int num1 = random.nextInt(20) + 1; // Random number between 1 and 20
  int num2 = random.nextInt(20) + 1;
  int answer = num1 + num2;

  return MathQuestion(num1, num2, "+", answer);
}
