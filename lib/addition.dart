import 'package:flutter/material.dart';
import 'package:mathsense/feedback.dart';
import 'package:mathsense/home_page.dart';
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
      debugShowCheckedModeBanner: false,
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
  String _question = ''; // Initialize _question with an empty string
  String _answerStatus = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initFlutterTts().then((_) {
      _speakWelcomeMessage();
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

  Future _repeatInstruction() async {
    await _flutterTts.speak(
        "Tap the top of the screen to hear the question and the bottom button to answer.");
  }

  Future _initSpeech() async {
    await _speechToText.initialize();
  }

  Future _speakWelcomeMessage() async {
    await _flutterTts.speak("Let's start with addition.");
    await _flutterTts.awaitSpeakCompletion(true);

    await _flutterTts.speak(
        "Tap the top of the screen to hear the question and the bottom button to answer.");
    await _flutterTts.awaitSpeakCompletion(true);

    generateQuestion(); // Now generate the question after instructions
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
  }

  Future _speakQuestion() async {
    await _flutterTts.speak(_question);

    setState(() {
      _isListening = false;
    });
  }

  Future _speakAnswerStatus(String message) async {
    await _flutterTts.speak(message);
  }

  void checkAnswer(String spokenText) async {
    try {
      int spokenNumber = int.parse(spokenText);
      if (spokenNumber == _result) {
        setState(() {
          _answerStatus = 'Correct';
        });
        await _speakAnswerStatus('Correct');
        await _speechToText.stop(); // Stop speech recognition
        setState(() {
          _isListening = false;
        });
        await Future.delayed(Duration(seconds: 1));
        generateQuestion(); // Generate new question after correct answer
      } else {
        setState(() {
          _answerStatus = 'Wrong, the correct answer is $_result';
        });
        await _speakAnswerStatus('Wrong, the correct answer is $_result');
        await _speechToText.stop(); // Stop speech recognition
        setState(() {
          _isListening = false;
        });
        await Future.delayed(Duration(seconds: 1));
        generateQuestion(); // Generate new question after incorrect answer
      }
    } catch (e) {
      setState(() {
        _answerStatus = 'Invalid input, please try again.';
      });
      await _speechToText.stop(); // Stop speech recognition
      setState(() {
        _isListening = false;
      });
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
      body: SafeArea(
        top: true,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: _isListening
                  ? null
                  : _speakQuestion, // Call _speakQuestion on tap
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
                color: Colors.black,
                child: Center(
                  child: Text(
                    _question.isNotEmpty
                        ? _question
                        : 'Tap to start the next question.',
                    style: TextStyle(
                        fontSize: 28,
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
                onPressed: _listen,
                child: Text(
                  'Answer',
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

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }
}
