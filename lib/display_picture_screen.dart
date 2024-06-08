import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'dart:io';

import 'package:tflite_v2/tflite_v2.dart';

class DisplayPictureScreen extends StatefulWidget {
  const DisplayPictureScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List _recognitions = [];
  double _imageWidth = 0;
  double _imageHeight = 0;
  bool _busy = false;
  // ScreenshotControllerを初期化
  final ScreenshotController screenshotController = ScreenshotController();

  // スクリーンショットを取得して画像を保存するメソッド
  Future<void> _saveImageWithBoxes() async {
    setState(() {
      _busy = true; // 画像保存中にフラグをセットして、インジケータを表示
    });
    // ScreenshotControllerを使用してスクリーンショットを取得
    final image = await screenshotController.capture();
    if (image != null) {
      // 画像を保存
      await ImageGallerySaver.saveImage(Uint8List.fromList(image));
      // 保存が完了したことをユーザーに通知
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像が保存されました')),
      );
    } else {
      // 画像がnullの場合はエラーメッセージを表示するか、適切な処理を行う
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像が保存に失敗しました。')),
      );
    }
    setState(() {
      _busy = false; // 画像保存が完了したらフラグを解除して、インジケータを非表示
    });
  }

  @override
  void initState() {
    super.initState();
    _loadModel();
    _detectObject(widget.imagePath);
  }

  _loadModel() async {
    await Tflite.loadModel(
      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/ssd_mobilenet.txt",
    );
  }

  _detectObject(String imagePath) async {

    setState(() {
      _busy = true; // TFLite処理中にフラグをセットして、インジケータを表示
    });

    var recognitions = await Tflite.detectObjectOnImage(
      path: imagePath,
      model: "SSDMobileNet",
      threshold: 0.5,
      numResultsPerClass: 1,
    );

    FileImage(File(imagePath)).resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        setState(() {
          _imageWidth = info.image.width.toDouble();
          _imageHeight = info.image.height.toDouble();
          _recognitions = recognitions!;
          _busy = false; // TFLite処理が完了したらフラグを解除して、インジケータを非表示にする
        });
      }),
    );
  }

  List<Widget> renderBoxes(Size screen) {
    if (_imageWidth == 0 || _imageHeight == 0) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageHeight * screen.width;

    return _recognitions.map((re) {
      return Positioned(
        left: re["rect"]["x"] * factorX,
        top: re["rect"]["y"] * factorY,
        width: re["rect"]["w"] * factorX,
        height: re["rect"]["h"] * factorY,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red,
              width: 3,
            ),
          ),
          child: Text(
            "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = Colors.red,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('撮れた写真')),
      body: Screenshot(
        controller: screenshotController,
        child: Stack(
          children: [
            Center(child: Image.file(File(widget.imagePath))),
            ...renderBoxes(screenSize),
            if (_busy) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _busy ? null : _saveImageWithBoxes,
        child: const Text('保存'),
      ),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
