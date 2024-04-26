import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/criteria.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RuleAddPage extends StatefulWidget {
  const RuleAddPage({super.key});

  @override
  State<StatefulWidget> createState() => _RuleAddPage();
}

class _RuleAddPage extends State<RuleAddPage> {
  // shared pref
  int? idBreed;
  String? strBreed;

  // dd criteria handler
  int? selectedCrit;

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
  void getBreedID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idBreed = prefs.getInt('id_breed');
      strBreed = prefs.getString('str_breed');
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

  // get criterias
  Future<List<Criteria>> fetchCriteriasRule() async {
    try {
      final response = await http.post(
          Uri.parse(
              'http://localhost/ta/Pawfect-Find-PHP/admin/criteria_rule.php'),
          body: {
            'breed_id': idBreed.toString(),
          });

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == 'Success') {
          List<Criteria> datas = List<Criteria>.from(
            json['data'].map((data) => Criteria.fromJson(data)),
          );

          return datas;
        } else {
          throw Exception(
              "Gagal menampilkan data kriteria: ${json['message']}");
        }
      } else {
        throw Exception(
            "Gagal menampilkan data kriteria: Status ${response.statusCode}.");
      }
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: $ex."),
        duration: Duration(seconds: 3),
      ));
      throw Exception("Terjadi kesalahan: $ex.");
    }
  }

  // method add data
  Future<void> addData(double cf) async {
    if (selectedCrit != null && selectedMB != null && selectedMD != null) {
      try {
        final response = await http.post(
            Uri.parse(
                "http://localhost/ta/Pawfect-Find-PHP/admin/rule_add.php"),
            body: {
              'breed_id': idBreed.toString(),
              'criteria_id': selectedCrit.toString(),
              'cf': cf.toStringAsFixed(1),
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
              "Gagal menambahkan data baru: Status ${response.statusCode}.");
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

  // method future drop down criterias
  Widget ddCriterias() => FutureBuilder<List<Criteria>>(
      future: fetchCriteriasRule(),
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
              if (selectedCrit == null) {
                selectedCrit = criterias[0].id;
              }

              return DropdownButtonFormField(
                value: selectedCrit,
                items: criterias.map((crit) {
                  return DropdownMenuItem(
                      value: crit.id, child: Text(crit.criteria));
                }).toList(),
                onChanged: (value) {
                  if (value != selectedCrit) {
                    setState(() {
                      selectedCrit = value;
                    });
                  }
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(8)),
              );
            } else {
              return Center(
                child: Text(
                  'Tidak terdapat kriteria yang belum ditambahkan.',
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
      : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Ras Anjing",
                style: GoogleFonts.nunito(fontSize: 12.0),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                strBreed ?? "Ras Anjing",
                style: GoogleFonts.nunito(
                    fontSize: 16.0, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Kriteria Baru",
                style: GoogleFonts.nunito(fontSize: 12.0),
              ),
              Row(
                children: [Expanded(child: ddCriterias())],
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Seberapa yakin Anda bahwa pernyataan ini benar?",
                style: GoogleFonts.nunito(fontSize: 12.0),
              ),
              Row(
                children: [
                  Expanded(child: ddCF(mbOptions, selectedMB, onChangedMB))
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
                  Expanded(child: ddCF(mdOptions, selectedMD, onChangedMD))
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Hasil Certainty Factor",
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
                            if (selectedMB != null && selectedMD != null) {
                              double cf =
                                  (selectedMB! - selectedMD!).clamp(-1.0, 1.0);

                              addData(cf);
                            }
                          },
                          child: Text(
                            "Simpan Aturan",
                            style: GoogleFonts.nunito(fontSize: 16),
                          )))
                ],
              )
            ],
          ),
        );

  @override
  void initState() {
    super.initState();

    getBreedID();

    selectedCrit = null;

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
            "Tambah Aturan",
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
