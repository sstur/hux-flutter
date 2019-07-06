import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostImage extends StatelessWidget {
  final String source;

  PostImage({Key key, @required this.source}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageURL = source.replaceFirst(
      new RegExp(r'/image/upload/v\d+/'),
      '/image/upload/w_1000/',
    );
    return AspectRatio(
      aspectRatio: 1,
      child: CachedNetworkImage(
        imageUrl: imageURL,
        fit: BoxFit.cover,
        alignment: FractionalOffset.center,
        // placeholder: CircularProgressIndicator(),
        // errorWidget: Icon(Icons.error),
      ),
    );
  }
}
