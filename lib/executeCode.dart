import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PythonCompilerScreen extends StatefulWidget {
  @override
  _PythonCompilerScreenState createState() => _PythonCompilerScreenState();
}

class _PythonCompilerScreenState extends State<PythonCompilerScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _output = '';
  String _error = '';

  Future<void> executeCode() async {
    const url = 'http://192.168.104.73:5000/execute'; // Flask server URL (Use this for Android Emulator)

    try {
      // Send a POST request to the Flask server
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': _codeController.text}), // Sending the code from the text field
      );

      // Check if the response status is OK (200)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Parse the response
        setState(() {
          _output = data['output'] ?? '';  // Update output
          _error = data['error'] ?? '';    // Update error (if any)
        });
      } else {
        setState(() {
          _output = '';
          _error = 'Failed to execute code.';
        });
      }
    } catch (e) {
      setState(() {
        _output = '';
        _error = 'Error: $e';  // Catch any exceptions and display the error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Python Compiler'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField for inputting Python code
            TextField(
              controller: _codeController,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: 'Write Python Code Here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: executeCode,  // Execute the Python code when pressed
                  child: Text('Run Code'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _codeController.clear(); // Clear the code input field
                      _output = '';
                      _error = '';
                    });
                  },
                  child: Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Output:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _output,
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),
            if (_error.isNotEmpty)
              Text(
                'Error:\n$_error',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
