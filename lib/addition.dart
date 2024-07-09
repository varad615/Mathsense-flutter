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
    _initFlutterTts().then((_) {
      _speakWelcomeMessage().then((_) {
        generateQuestion();
      });
    });
  }

  Future _initFlutterTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);

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

  Future _speakWelcomeMessage() async {
    await _flutterTts.speak("Let's start with addition.");
  }

  void generateQuestion() async {
    setState(() {
      _isListening = false;
      _answered = false;
    });

    do {
      _num1 = Random().nextInt(10);
      _num2 = Random().nextInt(10);
      _result = _num1 + _num2;
    } while (_result >= 1 && _result <= 10);

    _question = 'What is $_num1 plus $_num2?';
    await _speakQuestion();
  }

  Future _speakQuestion() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(_question);

    setState(() {
      _isListening = false;
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
          _isListening = false;
        });
        await _speechToText.stop();
        await Future.delayed(Duration(milliseconds: 500));
      } else {
        setState(() {
          _answerStatus = 'Wrong, please try again.';
        });
        await _speakAnswerStatus('Wrong, please try again.');
        setState(() {
          _isListening = false;
        });
        await _speechToText.stop();
      }
    } catch (e) {
      setState(() {
        _answerStatus = 'Invalid input, please try again.';
      });
      setState(() {
        _isListening = false;
      });
      await _speechToText.stop();
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

  void _repeatQuestion() async {
    await _speakQuestion();
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
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: _repeatQuestion,
                child: Text(
                  'Repeat Question',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: Size(double.infinity, 200),
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

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }
}
