import 'dart:async';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import './helpers/fetch.dart';
import './helpers/conversion.dart';

enum Event { updated }
enum AuthStatus { isAuthenticated, isNotAuthenticated }

class DataStore {
  StreamController<Event> _controller = StreamController.broadcast();
  String _authCode = '';
  Map<String, String> _user = Map();
  Map<String, Map<String, dynamic>> _posts = Map();
  List<String> _postKeys = [];
  Map<String, List<Map<String, dynamic>>> _commentsForPost = Map();

  Map<String, String> getCurrentUser() {
    return _user;
  }

  Future<AuthStatus> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final authCode = prefs.getString('authCode');
    if (authCode == null || authCode.isEmpty) {
      return AuthStatus.isNotAuthenticated;
    }
    final result = await fetch(
      url: '/users/me',
      headers: {'X-Auth': authCode},
    );
    if (result.isError) {
      return AuthStatus.isNotAuthenticated;
    }
    _authCode = authCode;
    _user = toStringStringMap(result.data['user']);
    notify();
    return AuthStatus.isAuthenticated;
  }

  Future<String> tryLogin(String email, String password) async {
    final result = await fetch(
      method: Method.post,
      url: '/auth',
      data: {'email': email, 'password': password},
    );
    if (result.isError) {
      return result.error;
    }
    final data = result.data;
    if (data['success'] == true) {
      _authCode = toString(data['authToken']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authCode', _authCode);
      _user = toStringStringMap(data['user']);
      notify();
      return '';
    } else {
      return 'Incorrect email or password.';
    }
  }

  void populatePosts(List<Map<String, dynamic>> newPosts) {
    List<String> postKeys = List();
    Map<String, Map<String, dynamic>> posts = Map();
    for (final post in newPosts) {
      final id = toString(post['id']);
      postKeys.add(id);
      posts[id] = post;
    }
    _postKeys = postKeys;
    _posts = posts;
    notify();
  }

  int getPostsCount() {
    return _postKeys.length;
  }

  Map<String, dynamic> getPostAtID(String id) {
    return _posts[id];
  }

  Map<String, dynamic> getPostAtIndex(int index) {
    final id = _postKeys[index];
    return _posts[id];
  }

  List<Map<String, dynamic>> getCommentsForPost(String id) {
    final comments = _commentsForPost[id];
    return (comments is List) ? comments : [];
  }

  Future<String> fetchPosts() async {
    final result = await fetch(
      url: '/posts',
      headers: {'X-Auth': _authCode},
    );
    if (result.isError) {
      return result.error;
    }
    final data = result.data;
    final List<Map<String, dynamic>> posts =
        data['posts'] is List ? validatePosts(data['posts']) : [];
    populatePosts(posts);
    return '';
  }

  Future<String> fetchComments(String id) async {
    final result = await fetch(
      url: '/posts/$id/comments',
      headers: {'X-Auth': _authCode},
    );
    if (result.isError) {
      return result.error;
    }
    final data = result.data;
    List<dynamic> commentList =
        (data['comments'] is List) ? data['comments'] : [];
    final comments = commentList.map((item) => toStringMap(item)).toList();
    _commentsForPost[id] = comments;
    // Update the comment count just in case the latest data is fresher.
    final existingPost = getPostAtID(id);
    if (existingPost is Map &&
        existingPost['commentCount'] != comments.length) {
      updatePost(id, (post) {
        post['commentCount'] = comments.length;
      });
    } else {
      notify();
    }
    return '';
  }

  void updatePost(
    String postID,
    void updatePost(Map<String, dynamic> post),
  ) {
    final post = _posts[postID];
    if (post != null) {
      var newPost = Map.of(post);
      updatePost(newPost);
      _posts[postID] = newPost;
      notify();
    }
  }

  void notify() {
    _controller.add(Event.updated);
  }

  StreamSubscription subscribe(Function listener) {
    return _controller.stream.listen((message) => listener());
  }

  void toggleLikedStatus(String id) {
    updatePost(id, (post) {
      if (post['likedByViewer'] == true) {
        post['likedByViewer'] = false;
        post['likeCount'] -= 1;
      } else {
        post['likedByViewer'] = true;
        post['likeCount'] += 1;
      }
    });
    fetch(
      method: Method.post,
      url: '/posts/$id/likes',
      headers: {'X-Auth': _authCode},
    );
  }

  void addComment(String id, String text) async {
    final now = DateTime.now();
    final owner = getCurrentUser();
    // Optimistic update:
    Map<String, dynamic> newComment = {
      'id': '_' +
          now.millisecondsSinceEpoch.toRadixString(16) +
          Random().nextInt(0xffffffff).toRadixString(16),
      'text': text,
      'owner': {
        'id': owner['id'],
        'name': owner['name'],
        'photo': owner['photo'],
      },
      'createdAt': now.toIso8601String(),
    };
    updatePost(id, (post) {
      var comments = _commentsForPost[id];
      if (comments is! List) {
        comments = [];
        _commentsForPost[id] = comments;
      }
      comments.add(newComment);
      post['commentCount'] += 1;
    });
    final result = await fetch(
      method: Method.post,
      url: '/posts/$id/comments',
      headers: {'X-Auth': _authCode},
      data: {'text': text},
    );
    if (result.isError) {
      return;
    }
    final comment = toStringMap(result.data['comment']);
    newComment['id'] = comment['id'];
    newComment['text'] = comment['text'];
    newComment['createdAt'] = comment['createdAt'];
    notify();
  }

  Future<void> addPost(String text, String photo) async {
    final now = DateTime.now();
    final owner = getCurrentUser();
    // Optimistic update:
    final tempKey = '_' +
        now.millisecondsSinceEpoch.toRadixString(16) +
        Random().nextInt(0xffffffff).toRadixString(16);
    Map<String, dynamic> newPost = {
      'id': tempKey,
      'photo': photo,
      'text': text,
      'likes': [],
      'comments': [],
      'owner': {
        'id': owner['id'],
        'name': owner['name'],
        'photo': owner['photo'],
      },
      'createdAt': now.toIso8601String(),
    };
    _insertPost(newPost);
    final result = await fetch(
      method: Method.post,
      url: '/posts',
      headers: {'X-Auth': _authCode},
      data: {'text': text, 'photo': photo},
    );
    if (result.isError) {
      return;
    }
    final post = toStringMap(result.data['post']);
    final newKey = toString(post['id']);
    // Update the post we created with the data from the server.
    newPost['id'] = newKey;
    newPost['text'] = post['text'];
    newPost['createdAt'] = post['createdAt'];
    _posts.remove(tempKey);
    _posts[newKey] = newPost;
    // Replace the temp key with the real key (id) returned from server.
    final newPostKeys =
        _postKeys.map((final key) => (key == tempKey) ? newKey : key).toList();
    _postKeys = newPostKeys;
    notify();
  }

  void _insertPost(Map<String, dynamic> post) {
    final id = toString(post['id']);
    final Map<String, Map<String, dynamic>> newPosts = Map();
    newPosts[id] = post;
    for (final key in _postKeys) {
      newPosts[key] = _posts[key];
    }
    _posts = newPosts;
    _postKeys.insert(0, id);
    notify();
  }

  List<Map<String, dynamic>> validatePosts(List<dynamic> inputList) {
    return inputList.map((item) => toStringMap(item)).toList();
  }
}
