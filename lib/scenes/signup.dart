import 'package:flutter/material.dart';

import '../helpers/fetch.dart';

class SignupScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Sign Up'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 40, 30, 20),
              child: SignupForm(),
            ),
          ],
        ),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  @override
  StatefulSignupForm createState() => StatefulSignupForm();
}

class StatefulSignupForm extends State<SignupForm> {
  final _focusNodeTwo = FocusNode();
  final _controllerOne = TextEditingController(text: '');
  final _controllerTwo = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: TextFormField(
              controller: _controllerOne,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
              cursorColor: Colors.black,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (String _text) {
                FocusScope.of(context).requestFocus(_focusNodeTwo);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: TextFormField(
              focusNode: _focusNodeTwo,
              controller: _controllerTwo,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email Address',
              ),
              cursorColor: Colors.black,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.go,
              onFieldSubmitted: (String _text) {
                submit(context);
              },
            ),
          ),
          RaisedButton(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'SIGN UP',
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

  void submit(BuildContext context) async {
    final name = _controllerOne.value.text;
    final email = _controllerTwo.value.text;
    final result = await fetch(
      method: Method.post,
      url: '/users',
      data: {'name': name, 'email': email},
    );
    if (result.isError) {
      final snackBar = SnackBar(content: Text(result.error));
      Scaffold.of(context).showSnackBar(snackBar);
    } else {
      _goBackToLogin(context: context);
    }
  }

  void _goBackToLogin({BuildContext context}) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
