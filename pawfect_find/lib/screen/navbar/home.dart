import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  double cardHeight = 130.0;

  Widget displayCard(
          ctxt, String route, String imagePath, double cardH, String txt) =>
      Expanded(
          child: InkWell(
              onTap: () {
                Navigator.pushNamed(ctxt, route);
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Ink.image(
                      image: AssetImage(imagePath),
                      height: cardH,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: cardH,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                            Colors.transparent,
                          ])),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Text(
                                txt,
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 48.0,
                            ),
                          ]),
                    )
                  ],
                ),
              )));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Pawfect Find',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
                onPressed: () {}, icon: Icon(Icons.bookmark_border_rounded))
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Temukan ras anjing yang \'pawfect\' untukmu.'),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Expanded(
                      child: Card(
                          elevation: 3,
                          shadowColor: Colors.grey.shade50,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(children: [
                              Row(children: [
                                Text(
                                    'Pilih salah satu yang sesuai dengan kondisimu:'),
                              ]),
                              SizedBox(
                                height: 8.0,
                              ),
                              Row(children: [
                                displayCard(
                                    context,
                                    'quiz',
                                    'assets/images/card_1.jpg',
                                    cardHeight,
                                    'Aku belum tahu ras anjing yang aku inginkan'),
                              ]),
                              SizedBox(
                                height: 8.0,
                              ),
                              Row(children: [
                                displayCard(
                                    context,
                                    'starter',
                                    'assets/images/card_2.jpg',
                                    cardHeight,
                                    'Aku sudah tahu ras anjing yang aku inginkan'),
                              ]),
                            ]),
                          )))
                ]),
              ],
            ),
          ),
        )
        // Column(children: <Widget>[
        //   Row(
        //       mainAxisAlignment: MainAxisAlignment.start,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: <Widget>[
        //         Expanded(
        //             child: Container(
        //           margin: EdgeInsets.only(left: 8.0, top: 24.0, right: 8.0),
        //           decoration: BoxDecoration(
        //             color: Colors.blue,
        //             borderRadius: BorderRadius.circular(12.0),
        //           ),
        //           alignment: Alignment.topCenter,
        //           width: 300.0,
        //           height: 200.0,
        //           child: Column(
        //             mainAxisAlignment: MainAxisAlignment.end,
        //             children: <Widget>[
        //               ElevatedButton(
        //                   onPressed: () {
        //                     Navigator.pushNamed(context, "starter");
        //                   },
        //                   child: Text('Ambil Kuis'))
        //             ],
        //           ),
        //         ))
        //       ])
        // ]),
        );
  }
}
