import 'package:flutter/material.dart';
import './feed.dart';
import '../data_store.dart';

class HomeScene extends StatelessWidget {
  final DataStore dataStore;

  HomeScene({Key key, @required this.dataStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              child: Text('Go to Feed'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedScene(dataStore: dataStore),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
