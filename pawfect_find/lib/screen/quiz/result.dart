import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/breed.dart';
import 'package:pawfect_find/class/history.dart';
import 'package:pawfect_find/class/recommendation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ResultPage();
}

class _ResultPage extends State<ResultPage> {
  // variable untuk result quiz
  List<Recommendation> listRecs = [];

  // method untuk ambil history id yang baru
  Future<String> getHistoryID() async {
    final prefs = await SharedPreferences.getInstance();
    String historyId = prefs.getString("history_id") ?? '';
    return historyId;
  }

  // method untuk fetch result dari table histories di db
  // Future<List<History>> fetchResult(String histId) async {
  Future<List<Recommendation>> fetchResult(String histId) async {
    final response = await http.post(
        Uri.parse("http://localhost/ta/Pawfect-Find-PHP/result.php"),
        body: {'history_id': histId});

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      List<Recommendation> result = List<Recommendation>.from(
          json['data'].map((rec) => Recommendation.fromJson(rec)));
      return result;
    } else {
      throw Exception("Failed to read API");
    }
  }

  // method untuk UI card result
  Widget cardResult(Recommendation recommendation) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, 'detail',
              arguments: {'breed_id': recommendation.breed_id});
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: FittedBox(
                fit: BoxFit.cover,
                child: Container(
                  height: 128.0,
                  width: 128.0,
                  child: Image.asset(
                    'assets/images/card_1.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                recommendation.breed,
                style: GoogleFonts.nunito(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                "${recommendation.cf.toStringAsFixed(2)}%",
                style: GoogleFonts.nunito(
                  fontSize: 16.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // method untuk display body
  Widget displayResult() => FutureBuilder<String>(
      future: getHistoryID(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            String histId = snapshot.data!;

            if (histId.isNotEmpty) {
              return FutureBuilder(
                  future: fetchResult(histId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData) {
                        listRecs = snapshot.data!;

                        return ListView.builder(
                            itemBuilder: (BuildContext ctxt, int index) {
                              return cardResult(listRecs[index]);
                            },
                            itemCount: listRecs.length);
                      } else {
                        return const Center(
                          child: Text('Tidak ada hasil ditemukan'),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  });
            } else {
              return const Center(
                child: Text('ID tidak valid'),
              );
            }
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      });

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              icon: Icon(Icons.arrow_back_ios_new_rounded)),
          title: Text(
            'Hasil Rekomendasi',
            style:
                GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Berdasarkan jawabanmu, ras anjing yang kami rekomendasikan adalah ...',
                style: GoogleFonts.nunito(fontSize: 16.0),
              ),
              SizedBox(
                height: 8.0,
              ),
              Expanded(child: displayResult())
            ],
          ),
        ));
  }
}
