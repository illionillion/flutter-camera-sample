import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart'; // CameraDescriptionをインポート
import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // 画面を縦向きに固定
  ]);
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}
