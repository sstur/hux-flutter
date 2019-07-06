import 'dart:io';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import '../data_store.dart';
import './gallery.dart';
import './compose.dart';

class CameraScene extends StatelessWidget {
  final DataStore dataStore;

  const CameraScene({
    Key key,
    @required this.dataStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CameraLoader(dataStore: dataStore);
  }
}

class CameraLoader extends StatefulWidget {
  final DataStore dataStore;

  const CameraLoader({Key key, @required this.dataStore}) : super(key: key);

  @override
  StatefulCameraLoader createState() => StatefulCameraLoader();
}

class StatefulCameraLoader extends State<CameraLoader> {
  bool isLoading = true;
  List<CameraDescription> cameras;
  CameraController cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    if (cameraController != null) {
      cameraController.dispose();
    }
    super.dispose();
  }

  void _initCamera() async {
    cameras = await availableCameras();
    if (cameras.length != 0) {
      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );
      await cameraController.initialize();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataStore = widget.dataStore;
    return Scaffold(
      appBar: AppBar(
        title: Text('Take Photo'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.wallpaper),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryScene(dataStore: dataStore),
                ),
              );
            },
          )
        ],
      ),
      body: Center(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (cameras.length == 0) {
      return Center(
        child: Text('No available cameras.'),
      );
    } else {
      return CameraView(
        dataStore: widget.dataStore,
        cameraController: cameraController,
      );
    }
  }
}

class CameraView extends StatelessWidget {
  final DataStore dataStore;
  final CameraController cameraController;

  const CameraView({
    Key key,
    @required this.dataStore,
    @required this.cameraController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(cameraController),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              width: 90,
              height: 90,
              child: RawMaterialButton(
                fillColor: Colors.white,
                shape: CircleBorder(
                  side: BorderSide(color: Color(0xffe8e8e8), width: 10),
                ),
                elevation: 0,
                onPressed: () {
                  takePicture(context, dataStore);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> takePicture(BuildContext context, DataStore dataStore) async {
    try {
      final tempDirectory = await getTemporaryDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
      final imagePath = join(tempDirectory.path, '$fileName.png');
      await cameraController.takePicture(imagePath);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ComposeScene(imageFile: File(imagePath), dataStore: dataStore),
        ),
      );
    } catch (e) {
      print('Error occurred taking picture.');
      print(e);
    }
  }
}
