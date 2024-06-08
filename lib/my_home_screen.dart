import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'take_picture_screen.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key, required this.title, required this.camera});

  final String title;
  final CameraDescription camera;

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  void _navigateToCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(camera: widget.camera),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _navigateToCamera,
              child: const Text('カメラを起動'),
            ),
          ],
        ),
      ),
    );
  }
}
