import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(DevicePreview(
    enabled: false,
    builder: (context) => MyApp(cameras: cameras),
  ));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription>? cameras;

  MyApp({this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: CameraScreen(cameras: cameras),
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription>? cameras;

  CameraScreen({this.cameras});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool isCameraInitialized = false;
  int selectedCameraIndex = 0;
  bool showOffset = false;

  @override
  void initState() {
    super.initState();
    if (widget.cameras != null) {
      initializeCamera();
    }
  }

  Future<void> initializeCamera() async {
    if (widget.cameras != null && widget.cameras!.isNotEmpty) {
      controller = CameraController(
        widget.cameras![selectedCameraIndex],
        ResolutionPreset.high,
      );
      await controller!.initialize();
      setState(() {
        isCameraInitialized = true;
      });
    }
  }

  void captureImage(BuildContext context) async {
    try {
      if (controller != null && controller!.value.isInitialized) {
        XFile file = await controller!.takePicture();
        cropImage(file, context);
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  void cropImage(XFile file, BuildContext context) async {
    try {
      // Load the image from the file
      img.Image? image = img.decodeImage(await file.readAsBytes());
      if (image == null) return;

      // Overlay dimensions and position
      double overlayWidth = 327.0;
      double overlayHeight = 203.0;

      // Get the screen size
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      // Calculate the scaling factors
      double scaleX = image.width / screenWidth;
      double scaleY = image.height / screenHeight;

      // Calculate the cropping rectangle
      int cropX = ((screenWidth - overlayWidth) / 2 * scaleX).toInt();
      int cropY = ((screenHeight - overlayHeight) / 2 * scaleY).toInt();
      int cropWidth = (overlayWidth * scaleX).toInt();
      int cropHeight = (overlayHeight * scaleY).toInt();

      // Ensure cropping rectangle is within image bounds
      cropX = cropX.clamp(0, image.width - 1);
      cropY = cropY.clamp(0, image.height - 1);
      cropWidth =
          (cropX + cropWidth > image.width) ? image.width - cropX : cropWidth;
      cropHeight = (cropY + cropHeight > image.height)
          ? image.height - cropY
          : cropHeight;

      // Crop the image
      img.Image croppedImage = img.copyCrop(image,
          x: cropX, y: cropY, width: cropWidth, height: cropHeight);

      // Convert cropped image to Uint8List
      final croppedBytes = Uint8List.fromList(img.encodeJpg(croppedImage));

      // Navigate to the next screen with the cropped image
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayImageScreen(imageBytes: croppedBytes),
        ),
      );
    } catch (e) {
      print('Error cropping image: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Overlay dimensions and position
    double overlayWidth = 327.0;
    double overlayHeight = 203.0;
    double overlayLeft = (screenWidth - overlayWidth) / 2;
    double overlayTop = (screenHeight - overlayHeight) / 2;

    return Scaffold(
      body: isCameraInitialized
          ? Stack(
              children: [
                Positioned.fill(child: CameraPreview(controller!)),
                if (showOffset)
                  Positioned(
                    left: overlayLeft,
                    top: overlayTop,
                    child: Container(
                      width: overlayWidth,
                      height: overlayHeight,
                      color: Colors.red.withOpacity(0.5),
                    ),
                  ),
                Positioned(
                  left: overlayLeft,
                  top: overlayTop,
                  child: Stack(
                    children: [
                      Container(
                        width: overlayWidth,
                        height: overlayHeight,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.transparent, width: 2),
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 5),
                              left: BorderSide(color: Colors.white, width: 5),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 5),
                              right: BorderSide(color: Colors.white, width: 5),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 5),
                              left: BorderSide(color: Colors.white, width: 5),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 5),
                              right: BorderSide(color: Colors.white, width: 5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: screenWidth * 0.5 - 55,
                  child: Row(
                    children: [
                      FloatingActionButton(
                        onPressed: () => captureImage(context),
                        child: Icon(Icons.camera),
                      ),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          Text("Show Offset"),
                          Switch(
                            value: showOffset,
                            onChanged: (value) {
                              setState(() {
                                showOffset = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class DisplayImageScreen extends StatelessWidget {
  final Uint8List imageBytes;

  DisplayImageScreen({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Captured Image'),
      ),
      body: Center(
        child: Image.memory(imageBytes),
      ),
    );
  }
}


// ?? Top Code is Working Fine so dont touch it
