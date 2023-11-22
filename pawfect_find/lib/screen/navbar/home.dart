import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(left: 8.0, top: 24.0, right: 8.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.topCenter,
                width: 300.0,
                height: 200.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget> [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "starter");
                        },
                        child: Text('Ambil Kuis'))
                  ],
                ),
              ))
            ])
      ]),
    );
  }
}
