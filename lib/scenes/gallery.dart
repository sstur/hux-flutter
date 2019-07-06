import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data_store.dart';
import './compose.dart';

class GalleryScene extends StatelessWidget {
  final DataStore dataStore;

  GalleryScene({Key key, @required this.dataStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Choose a Picture'),
      ),
      body: Center(
        child: RaisedButton(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Choose Picture',
              style: TextStyle(fontSize: 16),
            ),
          ),
          onPressed: () async {
            final file = await ImagePicker.pickImage(
              source: ImageSource.gallery,
            );
            if (file == null) {
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ComposeScene(imageFile: file, dataStore: dataStore),
              ),
            );
          },
        ),
      ),
    );
  }
}
