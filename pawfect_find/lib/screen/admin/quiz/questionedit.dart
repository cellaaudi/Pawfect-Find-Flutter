import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuestionEditPage extends StatefulWidget {
  const QuestionEditPage({super.key});

  @override
  State<StatefulWidget> createState() => _QuestionEditPage();
}

class _QuestionEditPage extends State<QuestionEditPage> {
  // shared pref
  int? idQue;
  int? sortQue;

  // controller
  TextEditingController _queController = TextEditingController();

  // method shared preferences id breed
  void getQueID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idQue = prefs.getInt('id_que');
      sortQue = prefs.getInt('sort_que');
      _queController.text = prefs.getString('str_que') ?? '';
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
                  prefs.remove('id_que');
                  prefs.remove('sort_que');
                  prefs.remove('str_que');

                  Navigator.popUntil(
                      context, ModalRoute.withName('quiz_index'));
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

  // method edit data
  Future<void> editData() async {
    if (_queController.text.isNotEmpty) {
      try {
        final response = await http.post(
            Uri.https(
                'cellaaudi.000webhostapp.com', '/admin/question_edit.php'),
            body: {'id': idQue.toString(), 'question': _queController.text});

        if (response.statusCode == 200) {
          Map<String, dynamic> json = jsonDecode(response.body);

          if (json['result'] == 'Success') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Berhasil memperbarui data."),
              duration: Duration(seconds: 3),
            ));

            final prefs = await SharedPreferences.getInstance();
            prefs.remove('id_que');
            prefs.remove('sort_que');
            prefs.remove('str_que');

            Navigator.pop(context);
          } else {
            throw Exception("Gagal memperbarui data: ${json['message']}");
          }
        } else {
          throw Exception("Gagal memperbarui data: ${response.statusCode}");
        }
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Terjadi kesalahan: $ex"),
          duration: Duration(seconds: 3),
        ));
        throw Exception("Terjadi kesalahan: $ex");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Data belum semua terisi."),
        duration: Duration(seconds: 3),
      ));
      throw Exception("Data belum semua terisi.");
    }
  }

  // method build body
  Widget buildBody() => idQue == null
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
                "Nomor Urut",
                style: GoogleFonts.nunito(fontSize: 12.0),
              ),
              Text(
                sortQue.toString(),
                style: GoogleFonts.nunito(
                    fontSize: 16.0, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Pertanyaan",
                style: GoogleFonts.nunito(fontSize: 12.0),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    maxLines: null,
                    controller: _queController,
                    decoration: InputDecoration(
                        hintText:
                            "Contoh: Apa warna bulu anjing yang kamu inginkan?",
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
                            "Simpan Perubahan",
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

    getQueID();
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
            "Perbarui Pertanyaan",
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
