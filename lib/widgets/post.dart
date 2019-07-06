import 'package:flutter/material.dart';

import './avatar.dart';
import '../helpers/formatDuration.dart';
import '../helpers/conversion.dart';
import './post_button.dart';
import './post_image.dart';

class Post extends StatelessWidget {
  final Map<String, dynamic> post;
  final Function onAuthorPress;
  final Function onImagePress;
  final Function onLikePress;
  final Function onCommentPress;

  Post(
      {Key key,
      @required this.post,
      @required this.onAuthorPress,
      @required this.onImagePress,
      @required this.onLikePress,
      @required this.onCommentPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageURL = toString(post['photo']);
    final owner = toStringMap(post['owner']);
    final createdAt = DateTime.parse(toString(post['createdAt']));
    final isLiked = toBool(post['likedByViewer']);
    final likeCount = toInt(post['likeCount']);
    final commentCount = toInt(post['commentCount']);
    return Column(
      children: [
        GestureDetector(
          onTap: () => onAuthorPress(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            child: Row(
              children: [
                Avatar(imageURL: toString(owner['photo'])),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      toString(owner['name']),
                      style: TextStyle(
                        fontSize: 19,
                        fontFamily: 'RobotoCondensed',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text(
                  formatDuration(createdAt, DateTime.now()),
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0x992d2d2d),
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onImagePress(),
          child: PostImage(source: imageURL),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 2, color: Color(0xfff0f0f0)),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                PostButton(
                  onPress: () => onLikePress(),
                  icon: isLiked
                      ? Icon(Icons.favorite, color: Color(0xfff7444e))
                      : Icon(Icons.favorite_border, color: Color(0xff000000)),
                  text: likeCount == 1
                      ? '1 Like'
                      : '${likeCount.toString()} Likes',
                ),
                PostButton(
                  onPress: () => onCommentPress(),
                  icon: Icon(Icons.speaker_notes),
                  text: commentCount == 1
                      ? '1 Comment'
                      : '${commentCount.toString()} Comments',
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(14, 12, 14, 24),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              toString(post['text']),
              style: TextStyle(fontSize: 17, height: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
