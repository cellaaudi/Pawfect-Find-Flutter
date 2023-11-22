import 'package:flutter/material.dart';

class QuizStarterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: <Widget>[
          Expanded(
            child: Text('Pilih kondisi Anda saat ini:'),
          ),
        ]),
        Row(
          children: <Widget>[
            Expanded(
                child: Container(
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
                          Navigator.pushNamed(context, "quiz");
                        },
                        child: Text('Ambil Kuis'))
                  ],
                ),
            ))
          ],
        )
      ],
    ));
  }
}
