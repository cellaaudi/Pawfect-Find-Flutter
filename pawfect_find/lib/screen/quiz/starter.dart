import 'dart:js';

import 'package:flutter/material.dart';

class QuizStarterPage extends StatelessWidget {
  Widget displayBody() => SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pilih keadaan yang mendeskripsikan keadaan Anda saat ini'),
            SizedBox(
              height: 16.0,
            ),
            // Card(
            //     clipBehavior: Clip.antiAlias,
            //     shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8)),
            //     child: Stack(
            //       alignment: Alignment.center,
            //       children: [
            //         Ink.image(
            //           image: NetworkImage(
            //               'https://images.pexels.com/photos/2071555/pexels-photo-2071555.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
            //           height: 240.0,
            //           fit: BoxFit.cover,
            //         ),
            //         Text("gsd")
            //       ],
            //     ))
            // Expanded(
            //     child: Container(
            //   decoration: BoxDecoration(
            //     color: Colors.blue,
            //     borderRadius: BorderRadius.circular(12.0),
            //   ),
            //   alignment: Alignment.topCenter,
            //   width: 300.0,
            //   height: 200.0,
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     children: <Widget>[
            //       ElevatedButton(
            //           onPressed: () {
            //             // Navigator.pushNamed(ctxt, "quiz");
            //           },
            //           child: Text('Ambil Kuis'))
            //     ],
            //   ),
            // )),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: displayBody());
  }
}
