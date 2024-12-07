import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mathsense/feedback.dart';
import 'package:mathsense/home_page.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(SubtractionApp());
}

class SubtractionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subtraction Solver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SubtractionPage(),
    );
  }
}

class SubtractionPage extends StatefulWidget {
  @override
  _SubtractionPageState createState() => _SubtractionPageState();
}

class _SubtractionPageState extends State<SubtractionPage> {
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
    _speak(
        "Let's start with subtraction. Tap the top of the screen to hear the question and the bottom button to answer.");
    _generateNewQuestion(
        shouldSpeak: false); // Generate the first question without speaking it
  }

  void _repeatInstruction() async {
    _speak(
        "Tap the top of the screen to hear the question and the bottom button to answer.");
  }

  void _generateNewQuestion({bool shouldSpeak = true}) {
    setState(() {
      _currentQuestion = generateSubtractionQuestion();
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
          if (val.hasConfidenceRating &&
              val.confidence > 0.75 &&
              !_processingAnswer) {
            setState(() {
              _text = val.recognizedWords;
              _checkAnswer(int.tryParse(_text) ?? 0);
            });
          }
        },
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 2),
        cancelOnError: true,
        partialResults: false,
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  // void _checkAnswer(int userAnswer) async {
  //   _processingAnswer = true;
  //   _stopListening();
  //
  //   if (userAnswer == _currentQuestion?.answer) {
  //     _speak("Correct!");
  //     _generateNewQuestion(shouldSpeak: false);
  //   } else {
  //     _speak("Wrong, the right answer is ${_currentQuestion?.answer}.");
  //     _generateNewQuestion(shouldSpeak: false);
  //   }
  // }
  int _correctCount = 0;
  int wrongQuoteIndex = 0;


  void _checkAnswer(int userAnswer) async {
    _processingAnswer = true;
    _stopListening();

    if (userAnswer == _currentQuestion?.answer) {
      _speak("Correct!");

      _correctCount++;

      if (_correctCount % 3 == 0) {
        // Array of phrases for correct answers
        List<String> correctPhrases = [
          "Good job!",
          "Well done!",
          "You're on fire!",
        ];

        // Play special speech after every 3 correct answers
        _speak(correctPhrases[Random().nextInt(correctPhrases.length)]);
      }

      _generateNewQuestion(shouldSpeak: false);
    } else {
      List<String> wrongQuotes = [
        "Wrong, the right answer is ${_currentQuestion?.answer}. Keep going!",
        "Wrong, the right answer is ${_currentQuestion?.answer}. Stay focused. You can do it!",
        "Wrong, the right answer is ${_currentQuestion?.answer}. Try the next one!",
      ];

      // _speak("Wrong, the right answer is ${_currentQuestion?.answer}.");
      _speak(wrongQuotes[wrongQuoteIndex]);
      wrongQuoteIndex = (wrongQuoteIndex + 1) % wrongQuotes.length;
      _generateNewQuestion(shouldSpeak: false);
    }
  }

  void _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  void _navigateToHome() {
    // Implement navigation to Home Page
  }

  void _navigateToFeedback() {
    // Implement navigation to Feedback Page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (_currentQuestion != null) {
                  _speak(_currentQuestion!.toSpeechString());
                }
              },
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
                color: Colors.black,
                child: Center(
                  child: Text(
                    _currentQuestion?.toString() ??
                        "Tap to hear the question...",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white), // White text for contrast
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _repeatInstruction,
                child: Text(
                  'Repeat Instruction',
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _isListening ? _stopListening : _startListening,
                child: Text(
                  _isListening ? 'Listening' : 'Answer',
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                },
                child: Text(
                  'Home',
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FeedbackPage()));
                },
                child: Text(
                  'Feedback',
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

  String toSpeechString() {
    return "$num1 ${operation == '-' ? 'minus' : operation} $num2";
  }
}

MathQuestion generateSubtractionQuestion() {
  Random random = Random();
  int num1;
  int num2;
  int answer;

  do {
    num1 = random.nextInt(30) + 20; // Ensure num1 is sufficiently large
    num2 = random.nextInt(15) + 1; // Ensure num2 is smaller
    answer = num1 - num2;
  } while (answer <= 10); // Repeat until the answer is greater than 10

  return MathQuestion(num1, num2, "-", answer);
}