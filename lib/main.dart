import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() => runApp(FaceDetectionApp());

class FaceDetectionApp extends StatelessWidget {
  const FaceDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FaceDetectionScreen(),
    );
  }
}

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  FaceDetectionScreenState createState() => FaceDetectionScreenState();
}

class FaceDetectionScreenState extends State<FaceDetectionScreen> {
  File? _image;
  final picker = ImagePicker();
  final FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  String _faceMessage = "Nenhum rosto detectado";

  Future<void> _detectFaces() async {
    if (_image == null) return;

    final inputImage = InputImage.fromFile(_image!);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    setState(() {
      if (faces.isNotEmpty) {
        Face face = faces.first;
        double? smileProb = face.smilingProbability;
        if (smileProb != null) {
          if (smileProb < 0.3) {
            _faceMessage = "Você está triste!";
          }
          if (smileProb > 0.3 && smileProb < 0.7) {
            _faceMessage = "Você está neutro!";
          }
          if (smileProb > 0.7 && smileProb < 1) {
            _faceMessage = "Você está sorridente!";
          }
        } else {
          _faceMessage = "Não foi possível detectar um sorriso.";
        }
      } else {
        _faceMessage = "Nenhum rosto detectado";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detector de Rosto',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF0047AB),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image != null
              ? Image.file(_image!, height: 300)
              : const Icon(Icons.image, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(_faceMessage, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, color: Color(0xFF0047AB)),
                label: const Text('Camera', style: TextStyle(color: Color(0xFF0047AB))),
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0047AB)),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, color: Color(0xFF0047AB)),
                label: const Text('Galeria', style: TextStyle(color: Color(0xFF0047AB))),
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0047AB)),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _faceMessage = "Analisando...";
      });
      await _detectFaces();
    }
  }
}
