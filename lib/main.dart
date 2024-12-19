import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(PythonCompilerApp());
}

class PythonCompilerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Python Compiler',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,

      home: PythonCompilerScreen(),
    );
  }
}

class PythonCompilerScreen extends StatefulWidget {
  @override
  _PythonCompilerScreenState createState() => _PythonCompilerScreenState();
}

class _PythonCompilerScreenState extends State<PythonCompilerScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _output = '';
  String _error = '';

  Future<void> executeCode() async {
    const url = 'http://127.0.0.1:5000/execute';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': _codeController.text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _output = data['output'] ?? '';
          _error = data['error'] ?? '';
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
        _error = 'Error: $e';
      });
    }
  }

  void clearOutput() {
    setState(() {
      _codeController.clear();
      _output = '';
      _error = '';
    });
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
                  onPressed: executeCode,
                  child: Text('Run Code'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: clearOutput,
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
