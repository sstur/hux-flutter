import 'dart:async';
import 'package:flutter/material.dart';

import '../widgets/avatar.dart';
import '../data_store.dart';

class CommentForm extends StatefulWidget {
  final DataStore dataStore;
  final String postID;

  CommentForm({Key key, @required this.dataStore, @required this.postID})
      : super(key: key);

  @override
  _StatefulCommentForm createState() => _StatefulCommentForm();
}

class _StatefulCommentForm extends State<CommentForm> {
  StreamSubscription _subscription;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subscription = widget.dataStore.subscribe(
      () => setState(() => {}),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarURL = widget.dataStore.getCurrentUser()['photo'];
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 2, color: Color(0xfff0f0f0)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Avatar(imageURL: avatarURL),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
                hintText: 'Write a comment',
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (String text) {
                submit(text);
              },
            ),
          ),
          FlatButton(
            child: Text('SEND'),
            textTheme: ButtonTextTheme.normal,
            onPressed: () {
              // Dismiss Keyboard
              FocusScope.of(context).requestFocus(FocusNode());
              submit(_controller.value.text);
            },
          ),
        ],
      ),
    );
  }

  void submit(String text) {
    if (text.isEmpty) {
      return;
    }
    final postID = widget.postID;
    widget.dataStore.addComment(postID, text);
    _controller.clear();
  }
}
