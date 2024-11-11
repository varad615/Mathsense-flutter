import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _sliderValue = 0.5; // Default value for the slider

  @override
  void initState() {
    super.initState();
    _loadSliderValue();
  }

  // Load the slider value from local storage
  Future<void> _loadSliderValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sliderValue = prefs.getDouble('speechRate') ?? 0.5; // Default to 0.5 if not set
    });
  }

  // Save the slider value to local storage
  Future<void> _setSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speechRate', _sliderValue);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Speed set to ${_sliderValue.toStringAsFixed(1)}x')),
    );
  }

  // Reset slider to its default value
  void _resetToDefault() {
    setState(() {
      _sliderValue = 0.5; // Reset slider value to default
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Speech Rate: ${_sliderValue.toStringAsFixed(1)}x',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Slider(
              value: _sliderValue,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: _sliderValue.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
              activeColor: Colors.black,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetToDefault,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(width: 2, color: Colors.black),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Default"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _setSpeed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(width: 2, color: Colors.black),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Set Speed"),
            ),
          ],
        ),
      ),
    );
  }
}
