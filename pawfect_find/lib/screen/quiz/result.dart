import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/history.dart';
import 'package:pawfect_find/class/recommendation.dart';
import 'package:pawfect_find/screen/detail/detail.dart';
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

  // shared pref
  int? idHistory;

  // method untuk ambil history id yang baru
  void getHistoryID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idHistory = prefs.getInt('id_history');
    });
  }

  // method fetch history
  Future<History> fetchHistory() async {
    try {
      final response = await http.post(
          Uri.parse("http://localhost/ta/Pawfect-Find-PHP/history_detail.php"),
          body: {'history_id': idHistory.toString()});

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == 'Success') {
          History result = History.fromJson(json['data']);

          // final prefs = await SharedPreferences.getInstance();
          // prefs.setString('json_answer', result.answer);

          return result;
        } else {
          throw Exception("Gagal menampilkan data: ${json['message']}.");
        }
      } else {
        throw Exception(
            "Gagal menampilkan data: Status ${response.statusCode}.");
      }
    } catch (ex) {
      throw Exception("Terjadi kesalahan: $ex");
    }
  }

  // method untuk fetch result dari table histories di db
  Future<List<Recommendation>> fetchResult() async {
    try {
      final response = await http.post(
          Uri.parse("http://localhost/ta/Pawfect-Find-PHP/result.php"),
          body: {'history_id': idHistory.toString()});

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == 'Success') {
          List<Recommendation> result = List<Recommendation>.from(
              json['data'].map((rec) => Recommendation.fromJson(rec)));

          return result;
        } else {
          throw Exception("Gagal menampilkan data: ${json['message']}.");
        }
      } else {
        throw Exception(
            "Gagal menampilkan data: Status ${response.statusCode}.");
      }
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $ex'),
        duration: Duration(seconds: 3),
      ));
      throw Exception("Terjadi kesalahan: $ex");
    }
  }

  // method dropdown
  Widget ddResult() => DecoratedBox(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black45, width: 1.0)),
        child: DropdownButton<String>(
          value: dropdownValue,
          items: <String>['Semua', '5', '10']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
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
      );

  // method string chosen criterias
  Text chosenCriterias(List<dynamic> answers) {
    if (answers.isEmpty) {
      return Text(
        "Tidak ada kriteria terpilih.",
        style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
        textAlign: TextAlign.center,
      );
    }

    String strCrit =
        answers.map((item) => item['criteria'].toString()).join(' - ');

    return Text(
      strCrit,
      style: GoogleFonts.nunito(fontSize: 16),
      textAlign: TextAlign.center,
    );
  }

  // method untuk UI card result
  Widget cardResult(Recommendation recommendation) => InkWell(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('id_breed', recommendation.breed_id);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailPage(
                      fromRec: true,
                    )));
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
                  recommendation.imgAdult,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator(),);
                  },
                  errorBuilder: (context, error, trace) {
                    return Image.asset(
                      "assets/logos/logo-black.png",
                      fit: BoxFit.cover,
                    );
                  },
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
  Widget displayResult() => idHistory == null
      ? Center(
          child: CircularProgressIndicator(),
        )
      : FutureBuilder(
          future: fetchResult(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                  ),
                );
              } else if (snapshot.hasData) {
                listRecs = snapshot.data!;

                if (dropdownValue == 'Semua') {
                  max = listRecs.length;
                } else {
                  max = int.parse(dropdownValue);
                }

                if (listRecs.isNotEmpty) {
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
                    itemCount: listRecs.length > max ? max : listRecs.length,
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  );
                } else {
                  return Center(
                    child: Text(
                      'Tidak ada hasil ditemukan',
                      style:
                          GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
              } else {
                return Center(
                  child: Text(
                    'Tidak ada hasil ditemukan',
                    style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          });

  // method build body
  Widget buildBody() => FutureBuilder<History>(
      future: fetchHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
              ),
            );
          } else if (snapshot.hasData) {
            History history = snapshot.data!;
            List<dynamic> answerList = jsonDecode(history.answer);

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      ddResult(),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    "Kriteria yang kamu pilih:",
                    style: GoogleFonts.nunito(fontSize: 16),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Center(
                    child: chosenCriterias(answerList),
                  ),
                  SizedBox(height: 16),
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
            );
          } else {
            return Center(
              child: Text(
                'Tidak ada hasil ditemukan',
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
              ),
            );
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

    getHistoryID();
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
            child: buildBody(),
          ),
        ));
  }
}
