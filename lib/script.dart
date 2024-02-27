import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:solo_rehearsal/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solo_rehearsal/image_read.dart';

class ScriptPage extends StatefulWidget {
  final Script? script;

  const ScriptPage({Key? key, this.script}) : super(key: key);

  @override
  _ScriptPageState createState() => _ScriptPageState();
}

enum TtsState { playing, stopped, paused }

class _ScriptPageState extends State<ScriptPage> {
  late FlutterTts _flutterTts;
  TtsState _ttsState = TtsState.stopped;
  bool _volumeHigh = true;
  int _currentTextIndex = 0;
  String _currentLabel = "Other characters:";
  bool _shouldStopReading = false;
  final List<TextEditingController> _textControllers = [];
  final List<Widget> _textFields = [];
  final bool _buttonsGenerated =
      false; // Added variable to track button generation
  TextEditingController titleController = TextEditingController();
  String? imagePath;

  @override
  void initState() {
    super.initState();
    initTts(); // Initialize FlutterTts here
    for (int i = 0; i < 6; i++) {
      addNewTextField();
    }
    if (widget.script != null) {
      titleController.text = widget.script!.title;
      imagePath = widget.script!.imagePath;
      for (int i = 0; i < widget.script!.textSections.length; i++) {
        if (i < _textControllers.length) {
          _textControllers[i].text = widget.script!.textSections[i];
        } else {
          addNewTextField();
          _textControllers[i].text = widget.script!.textSections[i];
        }
      }
    }
  }

  void addNewTextField() {
    var newController = TextEditingController();
    _textControllers.add(newController);
    setState(() {
      _textFields.add(createLabel(_currentLabel)); // Update this line
      _textFields.add(createTextField(newController));
      _currentLabel =
          (_currentLabel == "Other characters:") ? "You:" : "Other characters:";
    });
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
    titleController.dispose();
    _textControllers.forEach((controller) {
      controller.dispose();
    });
  }

  Widget createLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        labelText,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
    );
  }

  initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Playing");
        }
        _ttsState = TtsState.playing;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Complete");
        }
        _ttsState = TtsState.stopped;
        _currentTextIndex = 0; // Reset to the beginning after completion
      });
    });

    _flutterTts.setCancelHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Cancel");
        }
        _ttsState = TtsState.stopped;
        _currentTextIndex = 0; // Reset on cancel
      });
    });

    _flutterTts.setPauseHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Paused");
        }
        _ttsState = TtsState.paused;
      });
    });

    _flutterTts.setErrorHandler((message) {
      setState(() {
        if (kDebugMode) {
          print("Error: $message");
        }
        _ttsState = TtsState.stopped;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: TextField(
          controller: titleController,
          decoration: InputDecoration(hintText: "Enter script title"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                Navigator.pop(
                  context,
                  Script(
                    title: titleController.text,
                    imagePath: imagePath,
                    textSections: _textControllers.map((e) => e.text).toList(),
                  ),
                );
              } else {
                showAlertDialog(context);
              }
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Color.fromARGB(255, 75, 31, 83),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(height: 24.0),
            InkWell(
              onTap: pickImage, // Assign the pickImage function to onTap
              child: CircleAvatar(
                radius: 65,
                backgroundColor: Colors.grey,
                child: imagePath != null
                    ? ClipOval(
                        child: Image.file(
                          File(imagePath!),
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.photo_library,
                        size: 50,
                        color: Colors.white,
                      ),
              ),
            ),
            if (imagePath == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text('No image selected.'),
              ),
            const SizedBox(height: 15.0),
            cameraButton(),
            const SizedBox(height: 18.0),
            // Add the text fields here
            ..._textFields,
            if (!_buttonsGenerated) // Generate buttons only once
              Column(
                children: [
                  addButton(),
                  const SizedBox(height: 25.0),
                  playButton(),
                  const SizedBox(height: 6.0),
                  pauseResumeButton(),
                  const SizedBox(height: 6.0),
                  stopButton(),
                  const SizedBox(height: 15.0),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget cameraButton() {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: () {
            navigateToCameraScreen();
          },
          backgroundColor: const Color.fromARGB(255, 75, 31, 83),
          child: const Icon(Icons.camera_alt,
              color: Colors.white), // Set the icon color to white
          // Make the button circular
        ),
        const SizedBox(height: 8.0), // Add space between the button and text
        Text(
          'Take a picture of your script to have it inputted in!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget addButton() {
    return FloatingActionButton(
      onPressed: () {
        addNewTextField();
      },
      backgroundColor: const Color.fromARGB(255, 75, 31, 83),
      child: const Icon(Icons.add,
          color: Colors.white), // Set the icon color to white
    );
  }

  Widget playButton() {
    return TextButton(
      onPressed: () {
        if (_ttsState == TtsState.stopped) {
          _volumeHigh = true;
          speak();
        }
      },
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(Color.fromARGB(255, 75, 31, 83)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(30.0), // Make the button circular
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0), // Adjust the padding as needed
        child: Text(
          'Play',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22, // Adjust the font size as needed
          ),
        ),
      ),
    );
  }

  Widget pauseResumeButton() {
    if (_ttsState == TtsState.playing) {
      return TextButton(
        onPressed: pause,
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Color.fromARGB(255, 75, 31, 83)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(30.0), // Make the button circular
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0), // Adjust the padding as needed
          child: Text(
            'Pause',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19, // Adjust the font size as needed
            ),
          ),
        ),
      );
    } else if (_ttsState == TtsState.paused) {
      return TextButton(
        onPressed: resume,
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Color.fromARGB(255, 75, 31, 83)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(30.0), // Make the button circular
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0), // Adjust the padding as needed
          child: Text(
            'Resume',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19, // Adjust the font size as needed
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget stopButton() {
    return TextButton(
      onPressed: stop,
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(Color.fromARGB(255, 75, 31, 83)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(30.0), // Make the button circular
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0), // Adjust the padding as needed
        child: Text(
          'Stop',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19, // Adjust the font size as needed
          ),
        ),
      ),
    );
  }

  Future speak() async {
    if (_ttsState == TtsState.paused) {
      setState(() {
        _ttsState = TtsState.playing;
      });
    }
    _ttsState = TtsState.playing; // Set TTS state to playing

    int i = _currentTextIndex; // Initialize i with the current index
    _shouldStopReading = false; // Reset the stop flag

    while (i < _textControllers.length) {
      if (_shouldStopReading) {
        break; // Stop if the stop flag is set
      }

      String text = _textControllers[i].text;
      if (text.isNotEmpty) {
        await _flutterTts.setVolume(_volumeHigh ? 1 : 0);
        await _flutterTts.speak(text);

        if (_shouldStopReading) {
          break; // Stop if the stop flag is set
        }

        _volumeHigh = !_volumeHigh; // Toggle volume
        print(_currentTextIndex);
        print(_textControllers.length);

        while (_ttsState == TtsState.playing) {
          // Wait for TTS to finish speaking or pause/resume
          await Future.delayed(Duration(milliseconds: 100));
        }

        if (_shouldStopReading) {
          // If the "Stop" button was pressed, stop TTS immediately
          await _flutterTts.stop();
        }
      }
      i++;
    }

    if (_shouldStopReading) {
      // If the "Stop" button was pressed, stop TTS immediately
      await _flutterTts.stop();
    }

    _ttsState = TtsState.stopped; // Set TTS state to stopped
    _shouldStopReading = false; // Reset the stop flag
  }

  Future stop() async {
    _shouldStopReading = true; // Set the flag to stop reading immediately
    await _flutterTts.stop(); // Stop TTS immediately
  }

  Future pause() async {
    await _flutterTts.pause();
    setState(() {
      _ttsState = TtsState.paused;
    });
  }

  Future resume() async {
    await speak();
    _ttsState = TtsState.playing;
  }

  void updateTextFields(List<String> sections) {
    print("oh nice");
    setState(() {
      for (int i = 0; i < sections.length; i++) {
        if (i < _textControllers.length) {
          _textControllers[i].text = sections[i];
        } else {
          addNewTextField();
          _textControllers[i].text = sections[i];
        }
      }
      // Clear text in any remaining text fields if sections are fewer
      for (int i = sections.length; i < _textControllers.length; i++) {
        _textControllers[i].clear();
      }
    });
  }

  // Modify your `navigateToCameraScreen` function as follows:
  void navigateToCameraScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraScreen(onTextExtracted: updateTextFields),
      ),
    );

    // Check the result from CameraScreen
    if (result == 'backButtonPressed') {
      // Automatically press the back button in the app bar
      Scaffold.of(context).openDrawer();
    }
  }

  Widget createTextField(TextEditingController controller) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(25.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 75, 31, 83)),
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  // Function to show alert dialog
  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          content: Text(
            "Input a title to save your script",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black, // Set text color
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(
                  color:
                      Color.fromARGB(255, 75, 31, 83), // Set button text color
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
