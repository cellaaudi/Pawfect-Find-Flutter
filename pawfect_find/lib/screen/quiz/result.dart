import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/recommendation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ResultPage();
}

class _ResultPage extends State<ResultPage> {
  // variable untuk result quiz
  List<Recommendation> listRecs = [];

  // dropdown
  String dropdownValue = 'Semua';
  int max = 0;

  // method untuk ambil history id yang baru
  Future<String> getHistoryID() async {
    final prefs = await SharedPreferences.getInstance();
    String historyId = prefs.getString("id_history") ?? '';
    return historyId;
  }

  // method untuk fetch result dari table histories di db
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
  Widget cardResult(Recommendation recommendation) => InkWell(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('id_breed', recommendation.breed_id);
        
        Navigator.pushNamed(context, 'detail');
      },
      child: ListTile(
        leading: FittedBox(
          fit: BoxFit.cover,
          child: Container(
              height: 128.0,
              width: 128.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  "http://localhost/ta/Pawfect-Find-PHP/${recommendation.imgAdult}",
                  fit: BoxFit.cover,
                ),
              )),
        ),
        title: Text(
          recommendation.breed,
          style:
              GoogleFonts.nunito(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          "${recommendation.cf.toStringAsFixed(2)}%",
          style: GoogleFonts.nunito(
            fontSize: 16.0,
          ),
        ),
      ));

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

                        if (dropdownValue == 'Semua') {
                          max = listRecs.length;
                        } else {
                          max = int.parse(dropdownValue);
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext ctxt, int index) {
                            if (index < max) {
                              return cardResult(listRecs[index]);
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                          itemCount:
                              listRecs.length > max ? max : listRecs.length,
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
                        );
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
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('id_history');

                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded)),
          title: Text(
            'Hasil Rekomendasi',
            style:
                GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500.0),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Tampilkan hasil:",
                        style: GoogleFonts.nunito(fontSize: 16.0),
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border:
                                Border.all(color: Colors.black45, width: 1.0)),
                        child: DropdownButton<String>(
                          value: dropdownValue,
                          items: <String>['Semua', '5', '10']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                                value: value,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    value,
                                    style: GoogleFonts.nunito(fontSize: 16.0),
                                  ),
                                ));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          underline: Container(),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    'Berdasarkan jawabanmu, ras anjing yang kami rekomendasikan adalah ...',
                    style: GoogleFonts.nunito(fontSize: 16.0),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  displayResult()
                ],
              ),
            ),
          ),
        ));
  }
}
