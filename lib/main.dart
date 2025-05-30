import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/splash_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  // Ensure initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Get available cameras
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error initializing camera: $e.code\nError message: $e.message');
  }

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Opino App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF2196F3),
      ),
      home: SplashScreen(cameras: cameras),
      debugShowCheckedModeBanner: false,
    );
  }
}