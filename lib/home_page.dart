import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:solo_rehearsal/script.dart';

class Script {
  String title;
  String? imagePath;
  List<String> textSections;

  Script({required this.title, this.imagePath, required this.textSections});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imagePath': imagePath,
      'textSections': textSections,
    };
  }

  factory Script.fromFirestore(Map<String, dynamic> firestore) {
    return Script(
      title: firestore['title'],
      imagePath: firestore['imagePath'],
      textSections: List<String>.from(firestore['textSections'] ?? []),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  late CollectionReference<Map<String, dynamic>> _scriptsCollection;

  @override
  void initState() {
    super.initState();
    _scriptsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('scripts');
  }

  Future<void> addScript(Script newScript) async {
    await _scriptsCollection.add(newScript.toMap());
  }

  Future<void> editScript(Script script) async {
    final updatedScript = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScriptPage(script: script)),
    );
    if (updatedScript != null) {
      setState(() {
        // Update the script in the list with the updated data
        _scriptsCollection.doc(script.title).set(updatedScript.toMap());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text('Your Scripts'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _scriptsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final scripts = snapshot.data!.docs
              .map((doc) => Script.fromFirestore(doc.data()))
              .toList();

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
            ),
            itemCount: scripts.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  editScript(scripts[index]);
                },
                child: Hero(
                  tag: 'script_${scripts[index].title}',
                  // Unique tag for each script item
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(
                          8.0), // Add padding to create space around the content
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(
                                  8.0), // Add padding around the image
                              child: scripts[index].imagePath != null
                                  ? Image.file(
                                      File(scripts[index].imagePath!),
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.image),
                            ),
                          ),
                          SizedBox(
                              height:
                                  4.0), // Add some space between the image and the text
                          Text(
                            scripts[index].title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              // You can also specify other styles like color, fontSize, etc. here if needed
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newScript = await Navigator.push<Script>(
            context,
            MaterialPageRoute(builder: (context) => const ScriptPage()),
          );
          if (newScript != null) {
            setState(() {
              addScript(newScript);
            });
          }
        },
        backgroundColor: Color.fromARGB(255, 75, 31, 83),
        child: Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(), // Make the button circular
      ),
    );
  }
}
