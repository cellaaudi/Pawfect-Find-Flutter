import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/breed.dart';
import 'package:pawfect_find/class/history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final bool fromRec;

  DetailPage({Key? key, this.fromRec = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  // Shared Preferences
  int? idBreed;
  int? idHistory;
  // List<dynamic>? jsonAnswer;

  // method shared preferences
  void getBreedID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idBreed = prefs.getInt('id_breed');
    });
  }

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

//   Future<List<dynamic>> getJSONAnswer() async {
//     if (widget.fromRec) {
//     List<dynamic>? jsonAnswer;

//     final prefs = await SharedPreferences.getInstance();
//     String? answerPref = prefs.getString('json_answer');

//     if (answerPref != null) {
//         jsonAnswer = jsonDecode(answerPref);
//       }

// return jsonAnswer;
//     // setState(() {
//     //   if (answerPref != null) {
//     //     jsonAnswer = jsonDecode(answerPref);
//     //   }
//     // });
//     }
//   }

  // method untuk ambil data breed dari database
  Future<Breed> fetchBreed() async {
    try {
      final response = await http.post(
          Uri.parse("http://localhost/ta/Pawfect-Find-PHP/detail.php"),
          body: {'breed_id': idBreed.toString()});

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == 'Success') {
          Breed result = Breed.fromJson(json['data']);

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
        content: Text("Terjadi kesalahan: $ex."),
        duration: Duration(seconds: 3),
      ));

      throw Exception("Terjadi kesalahan: $ex");
    }
  }

  // method untuk foto anjing
  Widget imgDog(String path, String age, String name) => Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8.0,
      shadowColor: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        "http://localhost/ta/Pawfect-Find-PHP/$path"),
                    fit: BoxFit.cover)),
          ),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                ])),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$name $age",
                  style:
                      GoogleFonts.nunito(fontSize: 12.0, color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ));

  // method text
  Widget textDog(String val, String title) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(fontSize: 12.0),
          ),
          Text(
            val,
            style:
                GoogleFonts.nunito(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12.0),
        ],
      );

  // method double
  Widget dblDog(double min, double max, String title, String unit) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(fontSize: 12.0),
          ),
          Text(
            '${min.toString()} - ${max.toString()} $unit',
            style:
                GoogleFonts.nunito(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12.0),
        ],
      );

  // method tile data
  Widget tileData(bool fromRec, criterias, int index) {
    if (fromRec) {
      return FutureBuilder<History>(
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

                bool isMatch = answerList.any((answer) =>
                    answer['criteria_id'] == criterias['criteria_id']);

                Color color = isMatch ? Colors.green : Colors.red;
                Icon icon = isMatch
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      );

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color,
                    child: icon,
                  ),
                  title: Text(
                    criterias['criteria'],
                    style: GoogleFonts.nunito(fontSize: 16, color: color),
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    'Data tidak ditemukan.',
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
    } else {
      return ListTile(
        leading: CircleAvatar(
          child: Text(
            "${index + 1}",
            style: GoogleFonts.nunito(),
          ),
        ),
        title: Text(
          criterias['criteria'],
          style: GoogleFonts.nunito(fontSize: 16),
        ),
      );
    }
  }

  // method untuk build body
  Widget displayBody() => idBreed == null
      ? Center(
          child: CircularProgressIndicator(),
        )
      : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: FutureBuilder<Breed>(
              future: fetchBreed(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: GoogleFonts.nunito(
                            fontSize: 16, color: Colors.grey),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    Breed breed = snapshot.data!;

                    return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GridView(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, childAspectRatio: 1),
                            shrinkWrap: true,
                            children: [
                              imgDog(breed.imgPuppy, "muda", breed.breed),
                              imgDog(breed.imgAdult, "dewasa", breed.breed)
                            ],
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          Text(
                            breed.breed.toString(),
                            style: GoogleFonts.nunito(
                                fontSize: 24.0, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 16.0),
                          textDog(breed.group, "Kelompok"),
                          dblDog(
                              breed.heightMin, breed.heightMax, "Tinggi", "cm"),
                          dblDog(
                              breed.weightMin, breed.weightMax, "berat", "kg"),
                          dblDog(breed.lifeMin, breed.lifeMax,
                              "Kemungkinan Umur", "tahun"),
                          textDog(breed.origin, "Negara Asal"),
                          textDog(breed.colour, "Warna"),
                          textDog(breed.attention, "Perhatian Khusus"),
                          Text(
                            widget.fromRec
                                ? 'Kriteria yang sesuai dengan jawabanmu'
                                : 'Kriteria',
                            style: GoogleFonts.nunito(fontSize: 12.0),
                          ),
                          if (breed.criterias!.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: breed.criterias!.length,
                              itemBuilder: (context, index) => tileData(
                                  widget.fromRec,
                                  breed.criterias![index],
                                  index),
                            )
                          else
                            Center(
                              child: Text(
                                "Belum ada kriteria.",
                                style: GoogleFonts.nunito(
                                    fontSize: 16.0, color: Colors.grey),
                              ),
                            )
                        ]);
                  } else {
                    return Center(
                      child: Text(
                        'Data tidak ditemukan.',
                        style: GoogleFonts.nunito(
                            fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }));

  @override
  void initState() {
    super.initState();

    getBreedID();
    getHistoryID();

    // if (widget.fromRec) {
    //   getJSONAnswer();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.remove('id_breed');
              if (widget.fromRec) {
                prefs.remove('json_answer');
              }

              Navigator.pop(context);
            }),
        title: Text(
          'Informasi Ras Anjing',
          style:
              GoogleFonts.nunito(fontSize: 20.0, fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: displayBody(),
      ),
    );
  }
}
