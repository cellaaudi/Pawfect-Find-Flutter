import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  // method card bg
  Widget cardBg(Color? clr, Widget cardContent) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Card(
            elevation: 8,
            color: clr,
            shadowColor: Colors.grey.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: cardContent,
            ),
          ))
        ],
      );

  // method string card
  Widget displayTxt(String txt, double? sz, FontWeight weight) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Text(
            txt,
            style: GoogleFonts.nunito(
              fontSize: sz,
              fontWeight: weight,
            ),
          ))
        ],
      );

  // method untuk UI card
  Widget displayCard(
          ctxt, String route, String imagePath, double cardH, String txt) =>
      Row(
        children: [
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
                  )))
        ],
      );

  // method untuk body scaffold
  Widget displayBody(ctxt) => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            displayTxt("Temukan ras anjing yang 'pawfect' untukmu.", 16,
                FontWeight.w600),
            SizedBox(
              height: 16.0,
            ),
            cardBg(
                Colors.white,
                Column(children: [
                  displayTxt("Rekomendasi", 18, FontWeight.w800),
                  Divider(),
                  SizedBox(
                    height: 8,
                  ),
                  displayTxt("Pilih salah satu yang sesuai dengan kondisimu:",
                      16, FontWeight.w600),
                  SizedBox(
                    height: 8.0,
                  ),
                  displayCard(ctxt, 'quiz', 'assets/images/card_1.jpg', 130,
                      'Aku belum tahu ras anjing yang aku inginkan'),
                  SizedBox(
                    height: 8.0,
                  ),
                  displayCard(ctxt, 'choose', 'assets/images/card_2.jpg', 130,
                      'Aku sudah tahu ras anjing yang aku inginkan'),
                ])),
            SizedBox(
              height: 16.0,
            ),
            cardBg(
                Colors.red,
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "PERHATIAN",
                          style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        )
                      ],
                    ),
                    Divider(color: Colors.white),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: RichText(
                                text: TextSpan(
                                    text:
                                        "Hasil rekomendasi yang diberikan hanya sebagai bantuan pertama bagimu untuk menentukan ras anjing yang akan dipelihara.",
                                    style: GoogleFonts.nunito(
                                        fontSize: 16, color: Colors.white))))
                      ],
                    )
                  ],
                )),
          ],
        ),
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Pawfect Find',
            style:
                GoogleFonts.nunito(fontSize: 20.0, fontWeight: FontWeight.w800),
          ),
        ),
        body: displayBody(context));
  }
}
