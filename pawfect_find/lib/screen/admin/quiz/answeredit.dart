import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/choice.dart';
import 'package:pawfect_find/class/criteria.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnswerEditPage extends StatefulWidget {
  const AnswerEditPage({super.key});

  @override
  State<StatefulWidget> createState() => _AnswerAddPage();
}

class _AnswerAddPage extends State<AnswerEditPage> {
  // shared pref
  int? idChoice;

  // controller
  TextEditingController _choiceController = TextEditingController();

  // dd handler
  int? selectedCrit;

  // method shared preferences id breed
  void getChoiceID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idChoice = prefs.getInt('id_choice');
    });
  }

  // method back message
  void _backMessage() => showDialog<void>(
      context: context,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text(
            'Batalkan',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apa kamu yakin ingin keluar tanpa menyimpan?',
            style: GoogleFonts.nunito(fontSize: 16.0),
          ),
          actions: <Widget>[
            TextButton(
                style: TextButton.styleFrom(
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.nunito(),
                )),
            TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.remove('id_choice');

                  Navigator.popUntil(
                      context, ModalRoute.withName('que_detail'));
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
                child: Text(
                  'Keluar',
                  style: GoogleFonts.nunito(),
                ))
          ],
        );
      });

  // method fetch data
  Future<Choice> fetchData() async {
    try {
      final response = await http.post(
          Uri.https(
              'cellaaudi.000webhostapp.com', '/admin/choice_detail.php'),
          body: {
            'choice_id': idChoice.toString(),
          });

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == 'Success') {
          Choice result = Choice.fromJson(json['data']);

          _choiceController.text = result.choice;

          if (result.criteriaId != null) {
            selectedCrit = result.criteriaId;
          } else {
            selectedCrit = 0;
          }

          return result;
        } else {
          throw Exception(
              'Gagal menampilkan data: ${json["message"]}');
        }
      } else {
        throw Exception(
            'Gagal menampilkan data: Status ${response.statusCode}.');
      }
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $ex'),
        duration: Duration(seconds: 3),
      ));
      throw Exception('Terjadi kesalahan: $ex');
    }
  }

  // get criterias
  Future<List<Criteria>> fetchCriterias() async {
    final response = await http.post(
        Uri.https('cellaaudi.000webhostapp.com', '/admin/criteria.php'));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);

      List<Criteria> datas = List<Criteria>.from(
        json['data'].map((data) => Criteria.fromJson(data)),
      );

      // tambahkan null
      datas.insert(
          0, Criteria(id: 0, criteria: 'Tidak ada kriteria untuk jawaban ini'));

      return datas;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal menampilkan data kriteria."),
        duration: Duration(seconds: 3),
      ));
      throw Exception("Gagal menampilkan data kriteria.");
    }
  }

  // update data
  Future<void> editData() async {
    if (_choiceController.text.isNotEmpty && selectedCrit != null) {
      try {
        final response = await http.post(
            Uri.https(
                'cellaaudi.000webhostapp.com', '/admin/choice_edit.php'),
            body: {
              'id': idChoice.toString(),
              'choice': _choiceController.text,
              'crit_id': selectedCrit.toString(),
            });

        if (response.statusCode == 200) {
          Map<String, dynamic> json = jsonDecode(response.body);

          if (json['result'] == "Success") {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Berhasil menambahkan data baru."),
              duration: Duration(seconds: 3),
            ));

            Navigator.pop(context);
          } else {
            throw Exception("Gagal menambahkan data baru: ${json['message']}");
          }
        } else {
          throw Exception(
              'Gagal menambahkan data baru: Status ${response.statusCode}.');
        }
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Terjadi kesalahan: $ex'),
          duration: Duration(seconds: 3),
        ));
        throw Exception('Terjadi kesalahan: $ex');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Data belum semua terisi."),
        duration: Duration(seconds: 3),
      ));
    }
  }

  // method future drop down criterias
  Widget ddCriterias() => FutureBuilder<List<Criteria>>(
      future: fetchCriterias(),
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
            List<Criteria> criterias = snapshot.data!;

            if (criterias.isNotEmpty) {
              return DropdownButtonFormField(
                value: selectedCrit,
                items: criterias.map((crit) {
                  return DropdownMenuItem(
                      value: crit.id, child: Text(crit.criteria));
                }).toList(),
                onChanged: (value) {
                  selectedCrit = value;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(8)),
              );
            } else {
              return Center(
                child: Text(
                  'Gagal memuat data kriteria.',
                  style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                ),
              );
            }
          } else {
            return Center(
              child: Text(
                'Gagal memuat data kriteria.',
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      });

  // method build body
  Widget buildBody() => idChoice == null
      ? Center(
          child: CircularProgressIndicator(),
        )
      : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: FutureBuilder<Choice>(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style:
                          GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                    ),
                  );
                } else if (snapshot.hasData) {
                  Choice choice = snapshot.data!;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Pertanyaan",
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        choice.question,
                        style: GoogleFonts.nunito(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Pilihan Jawaban",
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Card(
                            child: Column(
                              children: [
                                TextField(
                                  maxLines: null,
                                  controller: _choiceController,
                                  decoration: InputDecoration(
                                      hintText: "Contoh: Hitam",
                                      border: OutlineInputBorder()),
                                ),
                                ddCriterias()
                              ],
                            ),
                          ))
                        ],
                      ),
                      SizedBox(
                        height: 48,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () => editData(),
                                  child: Text(
                                    "Simpan Perubahan",
                                    style: GoogleFonts.nunito(fontSize: 16),
                                  )))
                        ],
                      )
                    ],
                  );
                } else {
                  return Center(
                    child: Text(
                      'Data tidak ditemukan.',
                      style:
                          GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ));

  @override
  void initState() {
    super.initState();

    getChoiceID();
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        _backMessage();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => _backMessage(),
          ),
          title: Text(
            "Perbarui Pilihan Jawaban",
            style:
                GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: buildBody(),
          ),
        ),
      ));
}
