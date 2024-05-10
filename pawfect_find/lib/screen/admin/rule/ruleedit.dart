import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/rulerow.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RuleEditPage extends StatefulWidget {
  const RuleEditPage({super.key});

  @override
  State<StatefulWidget> createState() => _RuleEditPage();
}

class _RuleEditPage extends State<RuleEditPage> {
  // shared pref
  int? idBreed;
  int? idCriteria;

  // dd cf handler
  final mbOptions = {
    'Pasti tidak benar': 0.0,
    'Hampir pasti tidak benar': 0.2,
    'Mungkin tidak benar': 0.4,
    'Mungkin benar': 0.6,
    'Hampir pasti benar': 0.8,
    'Pasti benar': 1.0
  };

  final mdOptions = {
    'Pasti tidak salah': 0.0,
    'Hampir pasti tidak salah': 0.2,
    'Mungkin tidak salah': 0.4,
    'Mungkin salah': 0.6,
    'Hampir pasti salah': 0.8,
    'Pasti salah': 1.0,
  };

  double? selectedMB;
  double? selectedMD;

  // method shared preferences id breed
  void getShared() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idBreed = prefs.getInt('id_breed');
      idCriteria = prefs.getInt('id_criteria');
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
                onPressed: () => Navigator.popUntil(
                    context, ModalRoute.withName('rule_detail')),
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

  // method fecth data
  Future<RuleRow> fetchData() async {
    try {
      final response = await http.post(
          Uri.parse("http://localhost/ta/Pawfect-Find-PHP/admin/rule_row.php"),
          body: {
            'breed_id': idBreed.toString(),
            'crit_id': idCriteria.toString(),
          });

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == "Success") {
          RuleRow ruleRow = RuleRow.fromJson(json['data']);

          return ruleRow;
        } else {
          throw Exception("Gagal menampilkan data: ${json['message']}");
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
      throw Exception("Terjadi kesalahan: $ex.");
    }
  }

  // method edit data
  Future<void> editData(double cf) async {
    if (selectedMB != null && selectedMD != null) {
      try {
        final response = await http.post(
            Uri.parse(
                "http://localhost/ta/Pawfect-Find-PHP/admin/rule_edit.php"),
            body: {
              'breed_id': idBreed.toString(),
              'crit_id': idCriteria.toString(),
              'cf': cf.toStringAsFixed(1),
            });

        if (response.statusCode == 200) {
          Map<String, dynamic> json = jsonDecode(response.body);

          if (json['result'] == "Success") {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Berhasil memperbarui data."),
              duration: Duration(seconds: 3),
            ));

            Navigator.pop(context);
          } else {
            throw Exception("Gagal memperbarui data: ${json['message']}");
          }
        } else {
          throw Exception(
              "Gagal memperbarui data: Status ${response.statusCode}.");
        }
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Terjadi kesalahan: $ex."),
          duration: Duration(seconds: 3),
        ));
        throw Exception("Terjadi kesalahan: $ex.");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Data belum semua terisi."),
        duration: Duration(seconds: 3),
      ));
      throw Exception("Data belum semua terisi.");
    }
  }

  void onChangedMB(double? value) {
    setState(() {
      selectedMB = value;
    });
  }

  void onChangedMD(double? value) {
    setState(() {
      selectedMD = value;
    });
  }

  // display data db
  Widget dataDB(String title, String data) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(fontSize: 12.0),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            data,
            style:
                GoogleFonts.nunito(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 16,
          ),
        ],
      );

  // dd CF
  Widget ddCF(Map<String, double> options, double? selectedVar,
      Function(double?)? onChanged) {
    final ddOptions = options.entries
        .map((e) => DropdownMenuItem(value: e.value, child: Text(e.key)))
        .toList();

    return DropdownButtonFormField(
      value: selectedVar,
      items: ddOptions,
      onChanged: (value) {
        onChanged?.call(value);
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(), contentPadding: EdgeInsets.all(8)),
    );
  }

  // method build body
  Widget buildBody() => idBreed == null
      ? Center(
          child: CircularProgressIndicator(),
        )
      : FutureBuilder<RuleRow>(
          future: fetchData(),
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
                RuleRow data = snapshot.data!;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      dataDB("Ras Anjing", data.breed),
                      dataDB("Kriteria", data.criteria),
                      dataDB("Certainty Factor Lama", data.cf.toString()),
                      Text(
                        "Certainty Factor Baru",
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      Text(
                        "Seberapa yakin Anda bahwa pernyataan ini benar?",
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: ddCF(mbOptions, selectedMB, onChangedMB))
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Seberapa yakin Anda bahwa pernyataan ini salah?",
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: ddCF(mdOptions, selectedMD, onChangedMD))
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Hasil Certainty Factor Baru",
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        (selectedMB != null && selectedMD != null)
                            ? "${(selectedMB! - selectedMD!).toStringAsFixed(1)}"
                            : "Pilih nilai keyakinan terlebih dahulu",
                        style: GoogleFonts.nunito(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 48,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (selectedMB != null &&
                                        selectedMD != null) {
                                      double cf = (selectedMB! - selectedMD!)
                                          .clamp(-1.0, 1.0);

                                      editData(cf);
                                    }
                                  },
                                  child: Text(
                                    "Simpan Pembaruan",
                                    style: GoogleFonts.nunito(fontSize: 16),
                                  )))
                        ],
                      )
                    ],
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
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          });

  @override
  void initState() {
    super.initState();

    getShared();

    selectedMB = mbOptions.values.first;
    selectedMD = mdOptions.values.first;
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
            "Perbarui Aturan",
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
