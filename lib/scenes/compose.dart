import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import '../data_store.dart';
import '../helpers/fetch.dart';
import '../helpers/conversion.dart';

class ComposeScene extends StatelessWidget {
  final DataStore dataStore;
  final File imageFile;

  ComposeScene({
    Key key,
    @required this.dataStore,
    @required this.imageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: ComposeForm(
                dataStore: dataStore,
                imageFile: imageFile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ComposeForm extends StatefulWidget {
  final DataStore dataStore;
  final File imageFile;

  ComposeForm({
    Key key,
    @required this.dataStore,
    @required this.imageFile,
  }) : super(key: key);

  @override
  _StatefulComposeForm createState() => _StatefulComposeForm();
}

class _StatefulComposeForm extends State<ComposeForm> {
  // final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  Future<ApiResult> _uploadImage;
  bool isSubmitting = false;
  String showError = '';

  @override
  void initState() {
    super.initState();
    // Start the upload while the user is filling out the form.
    attemptImageUpload();
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = widget.imageFile;
    if (isSubmitting) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Form(
      // key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    alignment: FractionalOffset.center,
                    image: FileImage(imageFile),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Caption',
              ),
              cursorColor: Colors.black,
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (String _text) {
                submit(context);
              },
            ),
          ),
          RaisedButton(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'UPLOAD POST',
                style: TextStyle(fontSize: 16),
              ),
            ),
            onPressed: () {
              // Dismiss Keyboard
              FocusScope.of(context).requestFocus(FocusNode());
              submit(context);
            },
          ),
        ],
      ),
    );
  }

  void attemptImageUpload() {
    _uploadImage = sendFile(
      url: 'https://api.cloudinary.com/v1_1/huxapp/image/upload',
      fields: {'upload_preset': 'jld8hkgs'},
      files: {'file': widget.imageFile},
    );
  }

  void submit(BuildContext context) async {
    setState(() {
      isSubmitting = true;
    });
    final caption = _controller.value.text;
    final dataStore = widget.dataStore;
    // Wait for the upload to finish.
    final result = await _uploadImage;
    if (result.isError) {
      setState(() {
        isSubmitting = false;
        showError = result.error;
      });
      return null;
    }
    final imageURL = toString(result.data['secure_url']);
    await dataStore.addPost(caption, imageURL);
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
