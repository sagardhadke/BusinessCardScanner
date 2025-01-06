import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class MyContatOff extends StatefulWidget {
  const MyContatOff({super.key});

  @override
  State<MyContatOff> createState() => _MyContatOffState();
}

class _MyContatOffState extends State<MyContatOff> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  
  final double offsetX = 100; // X position
  final double offsetY = 200; // Y position
  final double width = 327; // Width of the container
  final double height = 203; // Height of the container

  @override
  void initState() {
    super.initState();
    // Initialize the camera
    _initializeCamera();
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    // Obtain the list of available cameras
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    // Create a CameraController
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    // Initialize the controller
    _initializeControllerFuture = _controller.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OffContainerMySet"),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Stack(
            children: [
              // Camera feed as the background
              Positioned.fill(
                child: CameraPreview(_controller),
              ),
              // Red container in the middle
              Center(
                child: Positioned(
                  left: offsetX, // X position
                  top: offsetY,  // Y position
                  child: Container(
                    width: width,   // Container width
                    height: height, // Container height
                    color: Colors.red, // Container color
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
