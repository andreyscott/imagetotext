import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imagetotext/claude_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // variable

  File? _image;
  String? _description;
  bool _isLoading = false;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxHeight: 1000,
        maxWidth: 1920,
        imageQuality: 85,
      );

      // image has been picked

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _analyseImage();
      }
    }
    // Error
    catch (e) {
      print('Error: $e');
    }
  }
// analayse image method

  Future<void> _analyseImage() async {
    if (_image == null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    //start analyzing the image

    try {
      final description = await ClaudeService.analyzeImage(_image!);

      setState(() {
        _description = description;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');

      setState(() {
        _isLoading = false;
      });
    }

    // call the api to analyze the image
    // set the description to the result of the api call
    // set the _isLoading to false
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('AI vision')),
        body: Column(children: [
          Container(
            height: 300,
            color: Colors.grey,
            child: _image != null
                ? Image.file(_image!)
                : const Center(child: Text('Choose image ..')),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: const Text("Take Photo"),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Text("Gallery"),
            )
          ]),
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_description != null)
            Text(_description!)
        ]));
  }
}
