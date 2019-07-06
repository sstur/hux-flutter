import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String imageURL;

  Avatar({Key key, @required this.imageURL}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        imageURL,
        width: 40,
        height: 40,
      ),
    );
  }
}
