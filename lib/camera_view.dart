import 'package:card_scanner/card_info.dart';
import 'package:card_scanner/card_scanner.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController _camera;
  bool _isDetecting = false;
  CardInfo card;

  @override
  void initState() {
    super.initState();

    initCam();
  }

  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (controller == null || !controller.value.isInitialized) {
  //     return;
  //   }
  //   if (state == AppLifecycleState.inactive) {
  //     controller?.dispose();
  //   } else if (state == AppLifecycleState.resumed) {
  //     if (controller != null) {
  //       initCam();
  //     }
  //   }
  // }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  void initCam() async {
    if (_camera != null) {
      await _camera.dispose();
    }

    try {
      cameras = await availableCameras();
      final CameraDescription description = cameras.first;

      _camera = CameraController(description, ResolutionPreset.high,
          enableAudio: false);
      await _camera.initialize();

      _camera.startImageStream((CameraImage image) async {
        if (_isDetecting) return;
        _isDetecting = true;
        var result = await CardScanner.processImage(
            image, description.sensorOrientation);
        _isDetecting = false;
        if (result?.cardNumber != null) {
          // _camera.stopImageStream();
          card = result;
        }
        setState(() {});
      });
    } on CameraException catch (e) {
      print(e.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_camera == null || !_camera.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
      aspectRatio: _camera.value.aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RotatedBox(
            quarterTurns:
                MediaQuery.of(context).orientation == Orientation.landscape
                    ? 3
                    : 0,
            child: AspectRatio(
              aspectRatio: _camera.value.aspectRatio,
              child: CameraPreview(_camera),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 220,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white),
              ),
            ),
          ),
          if (card?.cardNumber != null)
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.cardNumber,
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  Text(
                    card.expiry ?? '',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
