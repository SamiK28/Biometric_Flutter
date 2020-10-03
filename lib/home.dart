import 'dart:io';
import 'package:biometric/face_detect.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _file;
  List<VisionFace> _currentLabels = <VisionFace>[];

  FirebaseVisionFaceDetector detector = FirebaseVisionFaceDetector.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Biometric Prototype"),
        centerTitle: true,
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: FloatingActionButton.extended(
                  onPressed: pickImage,
                  heroTag: "face",
                  icon: Icon(Icons.face),
                  label: Text("Face Biometric"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: FloatingActionButton.extended(
                  onPressed: () {},
                  heroTag: "voice",
                  icon: Icon(Icons.multitrack_audio_rounded),
                  label: Text("Voice Biometric"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void pickImage() async {
    try {
      var file = await ImagePicker()
          .getImage(source: ImageSource.camera)
          .whenComplete(() => showProcessing());

      assert(file != null);
      _file = File(file.path);
      _currentLabels = await detector.detectFromPath(_file?.path);
      assert(_currentLabels != null);
      assert(_currentLabels.isNotEmpty);
      Navigator.of(context).pop();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctxt) => FaceDetector(
                    file: _file,
                    labels: _currentLabels,
                  )));
    } catch (e) {
      Navigator.of(context).pop();
      Flushbar(
        duration: Duration(seconds: 3),
        icon: Icon(
          Icons.info,
          color: Colors.blue,
        ),
        isDismissible: false,
        
        message: "Error! Please Try Again.",
      ).show(context);
      print(e.toString());
    }
  }

  void showProcessing() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Center(child: CircularProgressIndicator()),
        content: Text(
          "Processing...",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
