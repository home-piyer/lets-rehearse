import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraScreen extends StatefulWidget {
  final Function(List<String>) onTextExtracted;

  const CameraScreen({super.key, required this.onTextExtracted});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[0], // Select a camera, usually the first one
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _controller?.initialize();

      if (!mounted) {
        return;
      }

      setState(() {}); // Trigger a rebuild after camera initialization
    } else {
      // Handle the case where no cameras are available
      if (kDebugMode) {
        print("No cameras available.");
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Take a Picture'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            takePictureAndGetName();
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }

  void takePictureAndGetName() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller?.takePicture();
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          String characterSymbol = '';
          String characterName = '';

          return AlertDialog(
            title: const Text('Enter Character Symbol and Name'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Character Symbol'),
                  onChanged: (value) {
                    characterSymbol = value;
                  },
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Character Name'),
                  onChanged: (value) {
                    characterName = value;
                  },
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  processImageAndExtractText(
                      image!, characterSymbol, characterName);
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // void processImageAndExtractText(
  //     XFile image, String characterSymbol, String characterName) async {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return const Dialog(
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             CircularProgressIndicator(),
  //             Text("Processing..."),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  //   try {
  //     final inputImage = InputImage.fromFilePath(image.path);
  //     final textRecognizer = GoogleMlKit.vision.textRecognizer();
  //     final RecognizedText recognizedText =
  //         await textRecognizer.processImage(inputImage);

  //     List<String> sections = [];
  //     String currentSection = '';
  //     String characterPrompt = characterName + characterSymbol;
  //     bool inCharacterSection = false;

  //     for (TextBlock block in recognizedText.blocks) {
  //       for (TextLine line in block.lines) {
  //         if (!inCharacterSection) {
  //           // Check if the line contains the character prompt
  //           if (line.text.contains(characterPrompt)) {
  //             // Start a new section from the beginning to the character prompt
  //             sections.add(currentSection);
  //             currentSection = '${line.text}\n';
  //             inCharacterSection = true;
  //           } else {
  //             // Append to the current section
  //             currentSection += '${line.text}\n';
  //           }
  //         } else {
  //           // Check if the line contains the character symbol
  //           if (line.text.contains(characterSymbol)) {
  //             // Start a new section from the character prompt to the character symbol
  //             sections.add(currentSection);
  //             currentSection = '${line.text}\n';
  //             inCharacterSection = false;
  //           } else {
  //             // Append to the current section
  //             currentSection += '${line.text}\n';
  //           }
  //         }
  //       }
  //     }

  //     if (currentSection.isNotEmpty) {
  //       sections.add(currentSection); // Add the final section
  //     }

  //     textRecognizer.close();

  //     // Update the main controller's text fields
  //     widget.onTextExtracted(sections);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("OCR process failed: $e");
  //     }
  //     // Handle the error appropriately
  //   }
  //   // ignore: use_build_context_synchronously
  //   Navigator.pop(context); // Close the dialog after processing
  // }
  void processImageAndExtractText(
      XFile image, String characterSymbol, String characterName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              Text("Processing..."),
            ],
          ),
        );
      },
    );
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      List<String> sections = [];
      String currentSection = '';
      String characterPrompt = characterName + characterSymbol;
      bool inCharacterSection = false;

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String text = line.text.trim(); // Trim leading and trailing spaces

          if (text.isEmpty) {
            continue; // Skip empty lines
          }

          // Check if the line contains a number
          if (RegExp(r'^\d+$').hasMatch(text)) {
            continue; // Skip lines that are only numbers
          }

          // Remove content within parentheses and the parentheses themselves
          text = text.replaceAll(RegExp(r'\([^)]*\)'), '');

          if (!inCharacterSection) {
            // Check if the line contains the character prompt
            if (text.contains(characterPrompt)) {
              // Start a new section from the beginning to the character prompt
              sections.add(currentSection);
              currentSection = '$text\n';
              inCharacterSection = true;
            } else {
              // Append to the current section
              currentSection += '$text\n';
            }
          } else {
            // Check if the line contains the character symbol
            if (text.contains(characterSymbol)) {
              // Start a new section from the character prompt to the character symbol
              sections.add(currentSection);
              currentSection = '$text\n';
              inCharacterSection = false;
            } else {
              // Append to the current section
              currentSection += '$text\n';
            }
          }
        }
      }

      if (currentSection.isNotEmpty) {
        sections.add(currentSection); // Add the final section
      }

      textRecognizer.close();

      // Update the main controller's text fields
      widget.onTextExtracted(sections);

      // Close the dialog after processing
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print("OCR process failed: $e");
      }
      // Handle the error appropriately
    }
    // Return 'backButtonPressed' to indicate that the back button was pressed
    Navigator.of(context).pop('backButtonPressed');
  }
}
