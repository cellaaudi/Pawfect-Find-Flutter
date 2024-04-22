import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class CriteriaAddPage extends StatefulWidget {
  const CriteriaAddPage({super.key});

  @override
  State<StatefulWidget> createState() => _CriteriaAddPage();
}

class _CriteriaAddPage extends State<CriteriaAddPage> {
  // controller input
  TextEditingController _criteriaController = TextEditingController();

  // variable input
  String? criteria;

  // method tambah data
  Future<void> addData() async {
    if (_criteriaController.text.isNotEmpty) {
      try {
        final response = await http.post(
            Uri.parse(
                'http://localhost/ta/Pawfect-Find-PHP/admin/criteria_add.php'),
            body: {'criteria': _criteriaController.text});

        if (response.statusCode == 200) {
          Map<String, dynamic> json = jsonDecode(response.body);

          if (json['result'] == "Success") {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Berhasil menambahkan data baru."),
              duration: Duration(seconds: 3),
            ));

            Navigator.pop(context);
          } else {
            throw Exception("Gagal menambahkan data baru: ${json['message']}.");
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
    }
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
                    context, ModalRoute.withName('criteria_index')),
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
  Widget buildBody() => SingleChildScrollView(
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
                      hintText: "Contoh: Ukuran besar",
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
                        onPressed: () => addData(),
                        child: Text(
                          "Simpan",
                          style: GoogleFonts.nunito(fontSize: 16),
                        )))
              ],
            )
          ],
        ),
      );

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
              "Tambah Kriteria",
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
