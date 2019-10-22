import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoConnectionDialog extends StatefulWidget {

  createState() => new NoConnectionDialogState();
}

class NoConnectionDialogState extends State<NoConnectionDialog> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Нет подключения'),
      content: Text(""),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Попробовать снова'),
        )
      ],
    );
  }
}
