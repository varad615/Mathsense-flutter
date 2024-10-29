import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _sliderValue = 1.0; // Default value for the slider

  // Method to reset slider to its default value
  void _resetToDefault() {
    setState(() {
      _sliderValue = 1.0; // Reset slider value to default
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Speech Rate: ${_sliderValue.toStringAsFixed(1)}x',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Slider(
              value: _sliderValue,
              min: 0.5,
              max: 2.0,
              divisions: 15, // To show incremental steps
              label: _sliderValue.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetToDefault,
              child: Text("Default"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
