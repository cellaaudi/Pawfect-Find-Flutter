import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/history.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  double cardHeight = 130.0;

  // method fetch histories
  // Future<List<History>> fetchHistory(int idUser) async {
  //   final response = await http.post(
  //       Uri.parse("http://localhost/ta/Pawfect-Find-PHP/result.php"),
  //       body: {'id': idUser});

  //   if (response.statusCode == 200) {}
  // }

  // method untuk UI card
  Widget displayCard(
          ctxt, String route, String imagePath, double cardH, String txt) =>
      Expanded(
          child: InkWell(
              onTap: () {
                Navigator.pushNamed(ctxt, route);
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 8,
                shadowColor: Colors.grey.shade50,
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

  // method untuk body scaffold
  Widget displayBody(ctxt) => Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Temukan ras anjing yang \'pawfect\' untukmu.',
                    style: GoogleFonts.nunito(fontSize: 16.0),
                  ),
                ],
              ),
              SizedBox(
                height: 16.0,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                    child: Card(
                        elevation: 8,
                        shadowColor: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(children: [
                            Row(children: [
                              Text(
                                'Pilih salah satu yang sesuai dengan kondisimu:',
                                style: GoogleFonts.nunito(fontSize: 16.0),
                              ),
                            ]),
                            SizedBox(
                              height: 8.0,
                            ),
                            Row(children: [
                              displayCard(
                                  ctxt,
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
                                  ctxt,
                                  'choose',
                                  'assets/images/card_2.jpg',
                                  cardHeight,
                                  'Aku sudah tahu ras anjing yang aku inginkan'),
                            ]),
                          ]),
                        )))
              ]),
              SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: Card(
                    elevation: 8,
                    shadowColor: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Riwayat",
                                style: GoogleFonts.nunito(
                                    fontSize: 20, fontWeight: FontWeight.w800),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                  ))
                ],
              )
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Pawfect Find',
            style:
                GoogleFonts.nunito(fontSize: 20.0, fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
                onPressed: () {}, icon: Icon(Icons.bookmark_border_rounded))
          ],
        ),
        body: displayBody(context));
  }
}
