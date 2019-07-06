import 'package:flutter/material.dart';

class PostButton extends StatelessWidget {
  final Icon icon;
  final String text;
  final Function onPress;

  PostButton(
      {Key key,
      @required this.icon,
      @required this.text,
      @required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPress,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 7),
              child: icon,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'RobotoCondensed',
              ),
            )
          ],
        ),
      ),
    );
  }
}
