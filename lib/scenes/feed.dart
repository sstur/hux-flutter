import 'dart:async';

import 'package:flutter/material.dart';

import './camera.dart';
import './post.dart';
import '../helpers/conversion.dart';
import '../widgets/post.dart';
import '../data_store.dart';

class FeedScene extends StatelessWidget {
  final DataStore dataStore;

  FeedScene({Key key, @required this.dataStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Feed'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraScene(dataStore: dataStore),
                ),
              );
            },
          )
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: FeedView(dataStore: dataStore),
      ),
    );
  }
}

class FeedView extends StatefulWidget {
  final DataStore dataStore;

  FeedView({Key key, @required this.dataStore}) : super(key: key);

  @override
  _StatefulFeedView createState() => _StatefulFeedView();
}

class _StatefulFeedView extends State<FeedView> {
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
    final errorMsg = await widget.dataStore.fetchPosts();
    setState(() {
      _errorMsg = errorMsg;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_errorMsg.isNotEmpty) {
      return Center(
        child: Text(_errorMsg, textAlign: TextAlign.center),
      );
    }
    final goToDetails = (String id) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailScene(
                dataStore: widget.dataStore,
                postID: id,
              ),
        ),
      );
    };
    final listView = ListView.builder(
      itemCount: widget.dataStore.getPostsCount(),
      itemBuilder: (context, index) {
        final post = widget.dataStore.getPostAtIndex(index);
        if (post == null) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Text('Error: No post at index $index'),
          );
        }
        final postID = toString(post['id']);
        return Post(
          key: ValueKey(postID),
          post: post,
          onAuthorPress: () {},
          onImagePress: () => goToDetails(postID),
          onLikePress: () => widget.dataStore.toggleLikedStatus(postID),
          onCommentPress: () => goToDetails(postID),
        );
      },
    );
    return RefreshIndicator(
      child: listView,
      onRefresh: () async {
        _fetchData();
      },
    );
  }
}
