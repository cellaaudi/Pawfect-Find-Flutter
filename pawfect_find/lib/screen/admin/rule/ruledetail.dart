import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/rule.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RuleDetailPage extends StatefulWidget {
  const RuleDetailPage({super.key});

  @override
  State<StatefulWidget> createState() => _RuleDetailPage();
}

class _RuleDetailPage extends State<RuleDetailPage> {
  // method refresh
  void _refresh() => setState(() {});

  // Shared pref
  int? idBreed;
  String? strBreed;

  // method shared preferences id breed
  void getBreedID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idBreed = prefs.getInt('id_breed');
      strBreed = prefs.getString('str_breed');
    });
  }

  // method delete alert
  Future<void> _delMsg(criterias) async => showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text(
            'Hapus Aturan',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apa kamu yakin ingin menghapus "${criterias["criteria"]}" dari daftar kriteria $strBreed?',
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
                  bool deleted = await deleteData(criterias['criteria_id']);

                  if (deleted) {
                    Navigator.pop(context);
                  }
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
                child: Text(
                  'Hapus',
                  style: GoogleFonts.nunito(),
                ))
          ],
        );
      });

  // method fetch data
  Future<Rule> fetchData() async {
    try {
      final response = await http.post(
          Uri.parse(
              'http://localhost/ta/Pawfect-Find-PHP/admin/rule_detail.php'),
          body: {'id': idBreed.toString()});

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == 'Success') {
          Rule result = Rule.fromJson(json['data']);

          return result;
        } else {
          throw Exception('Gagal menampilkan data: ${json["message"]}.');
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

  // method delete data
  Future<bool> deleteData(int criteria_id) async {
    try {
      bool deleted = false;

      final response = await http.post(
          Uri.parse(
              "http://localhost/ta/Pawfect-Find-PHP/admin/rule_delete.php"),
          body: {
            'breed_id': idBreed.toString(),
            'criteria_id': criteria_id.toString(),
          });

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == 'Success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Berhasil hapus data."),
            duration: Duration(seconds: 3),
          ));

          deleted = true;
        } else {
          throw Exception("Gagal hapus data: ${json['message']}.");
        }
      } else {
        throw Exception("Gagal hapus data: Status ${response.statusCode}.");
      }

      return deleted;
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $ex'),
        duration: Duration(seconds: 3),
      ));

      throw Exception('Terjadi kesalahan: $ex');
    }
  }

  // method tile data
  Widget tileData(int breed_id, criterias, int index) => ListTile(
        leading: CircleAvatar(
          child: Text(
            "${index + 1}",
            style: GoogleFonts.nunito(),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              criterias['criteria'],
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            Text(
              "Certainty Factor: ${criterias['cf']}",
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
            )
          ],
        ),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setInt('id_breed', breed_id);
                prefs.setInt('id_criteria', criterias['criteria_id']);

                Navigator.pushNamed(context, 'rule_edit')
                    .then((value) => _refresh());
              },
              icon: Icon(Icons.edit_rounded),
              tooltip: "Perbarui data",
              style: IconButton.styleFrom(foregroundColor: Colors.blue),
            ),
            IconButton(
              onPressed: () => _delMsg(criterias).then((value) => _refresh()),
              icon: Icon(Icons.delete_rounded),
              tooltip: "Hapus data",
              style: IconButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      );

  // method build body
  Widget buildBody() => idBreed == null
      ? Center(
          child: CircularProgressIndicator(),
        )
      : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: FutureBuilder<Rule>(
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
                  Rule rule = snapshot.data!;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            rule.breedName,
                            style: GoogleFonts.nunito(
                                fontSize: 24, fontWeight: FontWeight.w800),
                          )
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child: ListTile(
                            leading: Text(
                              "No.",
                              style: GoogleFonts.nunito(
                                  fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            title: Text(
                              "Kriteria",
                              style: GoogleFonts.nunito(
                                  fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            trailing: Text(
                              "Aksi",
                              style: GoogleFonts.nunito(
                                  fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          )),
                        ],
                      ),
                      Divider(),
                      if (rule.criterias!.isNotEmpty)
                        ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) =>
                                tileData(rule.breedId, rule.criterias![index], index),
                            separatorBuilder: (context, index) => Divider(),
                            itemCount: rule.criterias!.length)
                      else
                        Center(
                          child: Text(
                            "Belum ada kriteria.",
                            style: GoogleFonts.nunito(
                                fontSize: 16.0, color: Colors.grey),
                          ),
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
          ),
        );

  @override
  void initState() {
    super.initState();

    getBreedID();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('id_breed');

                Navigator.pop(context);
              }),
          title: Text(
            'Detail Aturan',
            style:
                GoogleFonts.nunito(fontSize: 20.0, fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, 'rule_add')
                  .then((value) => _refresh()),
              icon: Icon(Icons.add_rounded),
              tooltip: "Tambah data baru",
            )
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500), child: buildBody()),
        ),
      );
}
