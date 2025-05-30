import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String? selectedCategory;
  PlatformFile? selectedFile;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _analysisResult = "";
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get isUploadEnabled => selectedFile != null && selectedCategory != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF2196F3),
                          Color(0xFF1976D2),
                          Color(0xFF1565C0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  CustomPaint(
                    painter: BubblePattern(),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 20,
                    right: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.person, color: Colors.white, size: 24),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Welcome!,',
                                    style: TextStyle(fontSize: 24, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w300),
                                  ),
                                  Text(
                                    ' Adam',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Let's check your medical reports",
                                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search medical tests...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blue[400],
                          size: 26,
                        ),
                        suffixIcon: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.tune,
                            color: Colors.blue[400],
                            size: 20,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Medical Categories',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('See All', style: TextStyle(color: Colors.blue[400], fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        enhancedCategoryButton(
                          title: 'Blood Test',
                          icon: Icons.bloodtype_outlined,
                          color: Color(0xFFFF5252),
                          isSelected: selectedCategory == 'Blood Test',
                        ),
                        SizedBox(width: 15),
                        enhancedCategoryButton(
                          title: 'MRI',
                          icon: Icons.medical_information_rounded,
                          color: Color(0xFF4CAF50),
                          isSelected: selectedCategory == 'MRI',
                        ),
                        SizedBox(width: 15),
                        enhancedCategoryButton(
                          title: 'CT Scan',
                          icon: Icons.medical_services_outlined,
                          color: Color(0xFF2196F3),
                          isSelected: selectedCategory == 'CT Scan',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Upload Medical File',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTapDown: (_) => _controller.forward(),
                    onTapUp: (_) => _controller.reverse(),
                    onTapCancel: () => _controller.reverse(),
                    onTap: _pickFile,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[50]!, Colors.blue[100]!.withOpacity(0.5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.blue[200]!, width: 2),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -30,
                              top: -30,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.blue[200]!.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.2),
                                          blurRadius: 15,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      selectedFile != null ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
                                      size: 40,
                                      color: Colors.blue[400],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    selectedFile?.name ?? 'Tap to upload file',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (selectedFile != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        '${(selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _startScanning,
                    child: Container(
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.qr_code_scanner, size: 30, color: Colors.blue[400]),
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Scan Document',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isUploadEnabled ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isUploadEnabled ? () => _analyzeFile() : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUploadEnabled ? Colors.blue[600] : Colors.grey[300],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: _isAnalyzing
                          ? CircularProgressIndicator(color: Colors.white)
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file, size: 24, color: isUploadEnabled ? Colors.white : Colors.grey[500]),
                          SizedBox(width: 12),
                          Text(
                            'Upload for Analysis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isUploadEnabled ? Colors.white : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget enhancedCategoryButton({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = title;
          });
        },
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
    width: 110,
    height: 140,
    decoration: BoxDecoration(
    color: isSelected ? color.withOpacity(0.15) : Colors.white,
    borderRadius: BorderRadius.circular(25),
    border: Border.all(color: isSelected ? color : Colors.grey[300]!, width: isSelected ? 2 : 1),
    boxShadow: [
    BoxShadow(
    color: isSelected ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
    blurRadius: 15,
    offset: Offset(0, 8),
    ),
    ],
    ),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
    shape: BoxShape.circle,
    ),
      child: Icon(icon, color: color, size: 32),
    ),
      SizedBox(height: 12),
      Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? color : Colors.grey[700],
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      if (isSelected)
        Container(
          margin: EdgeInsets.only(top: 8),
          width: 30,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
    ],
    ),
        ),
    );
  }

  Future<void> _analyzeFile() async {
    if (selectedFile == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.67.242:5000/upload'),
      );

      if (selectedFile!.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            selectedFile!.bytes!,
            filename: selectedFile!.name,
          ),
        );
      } else if (selectedFile!.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            selectedFile!.path!,
          ),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        setState(() {
          _analysisResult = jsonResponse['analysis'] ?? "No analysis available.";
        });
        _navigateToResults();
      } else {
        throw Exception('Failed to analyze file');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing file: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          selectedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: ${e.toString()}')),
      );
    }
  }

  Future<void> _startScanning() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    final scannedFile = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScannerScreen(camera: firstCamera)),
    );
    if (scannedFile != null) {
      setState(() {
        selectedFile = PlatformFile(
          name: 'scanned_image.jpg',
          size: scannedFile.lengthSync(),
          path: scannedFile.path,
        );
      });
    }
  }

  void _navigateToResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          category: selectedCategory!,
          fileName: selectedFile!.name,
          analysisResult: _analysisResult,
        ),
      ),
    );
  }
}

class BubblePattern extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final circles = [
      Offset(-50, -50),
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.1),
      Offset(size.width + 50, size.height * 0.5),
    ];
    for (var offset in circles) {
      canvas.drawCircle(offset, 100, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
// ... [Previous HomeScreen and BubblePattern classes remain the same] ...

class ScannerScreen extends StatefulWidget {
  final CameraDescription camera;

  const ScannerScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  File? _scannedImage;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      setState(() {
        _scannedImage = File(image.path);
      });
    } catch (e) {
      print(e);
    }
  }

  void _submitScan() {
    if (_scannedImage != null) {
      Navigator.pop(context, _scannedImage);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a picture first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_cameraController),
                Center(
                  child: Container(
                    width: 250,
                    height: 350,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(Icons.camera_alt, size: 40, color: Colors.blue[600]),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_scannedImage != null)
                        ElevatedButton(
                          onPressed: _submitScan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text(
                            'Use Photo',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  final String category;
  final String fileName;
  final String analysisResult;

  const ResultsScreen({
    Key? key,
    required this.category,
    required this.fileName,
    required this.analysisResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Category: $category',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'File Name: $fileName',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Results',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      analysisResult,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}