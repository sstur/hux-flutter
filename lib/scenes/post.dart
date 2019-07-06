import 'dart:async';
import 'package:flutter/material.dart';

import '../helpers/conversion.dart';
import '../helpers/formatDuration.dart';
import '../widgets/avatar.dart';
import '../widgets/post.dart';
import '../widgets/comment_form.dart';
import '../data_store.dart';

class PostDetailScene extends StatelessWidget {
  final DataStore dataStore;
  final String postID;

  PostDetailScene({Key key, @required this.dataStore, @required this.postID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
        centerTitle: false,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: PostDetailView(dataStore: dataStore, postID: postID),
      ),
    );
  }
}

class PostDetailView extends StatefulWidget {
  final DataStore dataStore;
  final String postID;

  PostDetailView({Key key, @required this.dataStore, @required this.postID})
      : super(key: key);

  @override
  _StatefulPostDetailView createState() => _StatefulPostDetailView();
}

class _StatefulPostDetailView extends State<PostDetailView> {
  bool _isLoading = true;
  String _errorMsg = '';
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.dataStore.subscribe(
      () => setState(() => {}),
    );
    _fetchData();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _fetchData() async {
    final id = widget.postID;
    final errorMsg = await widget.dataStore.fetchComments(id);
    setState(() {
      _isLoading = false;
      _errorMsg = errorMsg;
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.postID;
    final post = widget.dataStore.getPostAtID(id);
    final comments = widget.dataStore.getCommentsForPost(id);
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Post(
                  post: post,
                  onAuthorPress: () {},
                  onImagePress: () {},
                  onLikePress: () => widget.dataStore.toggleLikedStatus(id),
                  onCommentPress: () {},
                ),
                CommentsView(
                  isLoading: _isLoading,
                  loadingError: _errorMsg,
                  comments: comments,
                ),
              ],
            ),
          ),
          CommentForm(
            postID: widget.postID,
            dataStore: widget.dataStore,
          ),
        ],
      ),
    );
  }
}

class CommentsView extends StatelessWidget {
  final bool isLoading;
  final String loadingError;
  final List<Map<String, dynamic>> comments;

  CommentsView(
      {Key key,
      @required this.comments,
      @required this.isLoading,
      @required this.loadingError})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }
    if (loadingError.isNotEmpty) {
      return Text(
        loadingError,
        textAlign: TextAlign.center,
      );
    }
    final headerText = comments.length == 0
        ? 'No comments yet.'
        : 'Comments (${comments.length})';
    List<Widget> rows = [
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              headerText,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ];
    rows.addAll(
      comments.map((comment) => CommentView(comment: comment)).toList(),
    );
    return Column(children: rows);
  }
}

class CommentView extends StatelessWidget {
  final Map<String, dynamic> comment;

  CommentView({Key key, @required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final owner = toStringMap(comment['owner']);
    final createdAt = DateTime.parse(comment['createdAt']);
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Avatar(imageURL: toString(owner['photo'])),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(
                    text: toString(owner['name']) + ':',
                    children: [
                      TextSpan(
                        text: ' ' + toString(comment['text']),
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                Text(
                  formatDuration(createdAt, DateTime.now()) + ' ago',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0x992d2d2d),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
