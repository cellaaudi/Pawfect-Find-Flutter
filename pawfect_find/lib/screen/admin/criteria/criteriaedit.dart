import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CriteriaEditPage extends StatefulWidget {
  const CriteriaEditPage({super.key});

  @override
  State<StatefulWidget> createState() => _CriteriaEditPage();
}

class _CriteriaEditPage extends State<CriteriaEditPage> {
  // controller input
  TextEditingController _criteriaController = TextEditingController();

  // variable input
  String? criteria;

  // Shared Preferences
  int idCriteria = 0;

  // method ambil id criteria
  void getCriteriaID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idCriteria = prefs.getInt('id_criteria') ?? 0;
      criteria = prefs.getString('str_criteria') ?? '';
    });

    _criteriaController.text = criteria ?? "";
  }

  // method tambah data
  Future<void> editData() async {
    if (_criteriaController.text.isNotEmpty) {
      try {
        final response = await http.post(
            Uri.https(
                'cellaaudi.000webhostapp.com', '/admin/criteria_edit.php'),
            body: {
              'id': idCriteria.toString(),
              'criteria': _criteriaController.text,
            });

        if (response.statusCode == 200) {
          Map<String, dynamic> json = jsonDecode(response.body);

          if (json['result'] == "Success") {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Berhasil memperbarui data."),
              duration: Duration(seconds: 3),
            ));

            final prefs = await SharedPreferences.getInstance();
            prefs.remove('id_criteria');
            prefs.remove('str_criteria');

            Navigator.pop(context);
          } else {
            throw Exception("Gagal memperbarui data: ${json['message']}.");
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
    }
  }

  // method back message
  void _backMessage() async => showDialog<void>(
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
                  prefs.remove('id_criteria');
                  prefs.remove('str_criteria');

                  Navigator.popUntil(
                      context, ModalRoute.withName('criteria_index'));
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

  // method untuk build body
  Widget buildBody() => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text("Kriteria", style: GoogleFonts.nunito(fontSize: 14)),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _criteriaController,
                  onChanged: (value) {
                    setState(() {
                      criteria = value;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: "Kriteria baru ...",
                      border: OutlineInputBorder()),
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
                          "Simpan Pembaruan",
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

    getCriteriaID();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
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
              "Perbarui Kriteria",
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
}
