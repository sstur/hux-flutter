import 'package:flutter/material.dart';

import './feed.dart';
import './signup.dart';
import '../data_store.dart';

class LoginScene extends StatelessWidget {
  final DataStore dataStore;

  LoginScene({Key key, @required this.dataStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Welcome'),
        actions: [
          FlatButton(
            child: Text(
              'SIGN UP',
              style: TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xfff7444e)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignupScene(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LoginView(dataStore: dataStore),
      ),
    );
  }
}

class LoginView extends StatefulWidget {
  final DataStore dataStore;

  LoginView({
    Key key,
    @required this.dataStore,
  }) : super(key: key);

  @override
  StatefulLoginView createState() => StatefulLoginView();
}

class StatefulLoginView extends State<LoginView> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: Text('Loading...'));
    }
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 70),
          child: AspectRatio(
            aspectRatio: 1.224,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  alignment: FractionalOffset.center,
                  image: AssetImage('assets/login_graphic.png'),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: LoginForm(
            onSubmit: (String email, String password) {
              tryLogin(context, email, password);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _checkAuth() async {
    final dataStore = widget.dataStore;
    final authStatus = await dataStore.checkAuth();
    // TODO: What if there is a network error checking auth?
    if (authStatus == AuthStatus.isAuthenticated) {
      _goToFeed(context: context, dataStore: dataStore);
    } else {
      setState(() => isLoading = false);
    }
  }

  void tryLogin(BuildContext context, String email, String password) async {
    final dataStore = widget.dataStore;
    final errorMsg = await dataStore.tryLogin(email, password);
    if (errorMsg.isEmpty) {
      _goToFeed(context: context, dataStore: dataStore);
    } else {
      final snackBar = SnackBar(content: Text(errorMsg));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  void _goToFeed({BuildContext context, DataStore dataStore}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FeedScene(dataStore: dataStore),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final void Function(String, String) onSubmit;

  LoginForm({
    Key key,
    @required this.onSubmit,
  }) : super(key: key);

  @override
  StatefulLoginForm createState() => StatefulLoginForm();
}

class StatefulLoginForm extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _focusNodeTwo = FocusNode();
  final _controllerOne = TextEditingController(text: '');
  final _controllerTwo = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: TextFormField(
              controller: _controllerOne,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email address',
              ),
              cursorColor: Colors.black,
              keyboardType: TextInputType.emailAddress,
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
                labelText: 'Password',
              ),
              obscureText: true,
              cursorColor: Colors.black,
              textInputAction: TextInputAction.go,
              onFieldSubmitted: (String _text) {
                submit();
              },
            ),
          ),
          RaisedButton(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'LOG IN',
                style: TextStyle(fontSize: 16),
              ),
            ),
            onPressed: () {
              // Dismiss Keyboard
              FocusScope.of(context).requestFocus(FocusNode());
              submit();
            },
          ),
        ],
      ),
    );
  }

  void submit() {
    widget.onSubmit(
      _controllerOne.value.text,
      _controllerTwo.value.text,
    );
  }
}
