import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

void main() {
  runApp(Addition());
}

class Addition extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _answered = false;
  late int _num1;
  late int _num2;
  late int _result;
  late String _question;
  String _answerStatus = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initFlutterTts();
    generateQuestion();
  }

  Future _initFlutterTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);

    // Speak a starting sentence when the application launches
    await _flutterTts
        .speak("Let's start with addition. Tap the screen to answer.");

    _flutterTts.setStartHandler(() {
      setState(() {
        _isListening = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isListening = false;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: $err");
        _isListening = false;
      });
    });
  }

  Future _initSpeech() async {
    await _speechToText.initialize();
  }

  void generateQuestion() async {
    setState(() {
      _isListening = false;
      _answered = false;
    });
    _num1 = Random().nextInt(10);
    _num2 = Random().nextInt(10);
    _result = _num1 + _num2;
    _question = 'What is $_num1 plus $_num2?';
    await _speakQuestion();
  }

  Future _speakQuestion() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(_question);

    // Allow tapping the screen to answer after speaking the question
    setState(() {
      _isListening = false; // Not listening initially after asking question
    });
  }

  Future _speakAnswerStatus(String message) async {
    if (message == 'Correct' || message == 'Wrong, please try again.') {
      await _flutterTts.speak(message);
    }
  }

void checkAnswer(String spokenText) async {
  try {
    int spokenNumber = int.parse(spokenText);
    if (spokenNumber == _result) {
      setState(() {
        _answerStatus = 'Correct';
      });
      await _speakAnswerStatus('Correct');
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _isListening = false; // Stop listening
      });
      await _speechToText.stop(); // Stop the speech recognition
      await Future.delayed(Duration(milliseconds: 500)); // Wait for 0.5 seconds
      generateQuestion(); // Generate a new question
    } else {
      setState(() {
        _answerStatus = 'Wrong, please try again.';
      });
      await _speakAnswerStatus('Wrong, please try again.');
      setState(() {
        _isListening = false; // Stop listening
      });
      await _speechToText.stop(); // Stop the speech recognition
    }
  } catch (e) {
    setState(() {
      _answerStatus = 'Invalid input, please try again.';
    });
    setState(() {
      _isListening = false; // Stop listening
    });
    await _speechToText.stop(); // Stop the speech recognition
  }
}

  void _listen() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      await _speechToText.listen(
          onResult: (val) => checkAnswer(val.recognizedWords));
      setState(() {
        _isListening = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Addition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: _isListening ? null : generateQuestion,
                child: Text(
                  'Next Question',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              _question != null ? _question : '',
              style: TextStyle(fontSize: 24),
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: _listen,
                child: Text(
                  'Answer',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }
}
