import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/question.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizIndexPage extends StatefulWidget {
  const QuizIndexPage({super.key});

  @override
  State<StatefulWidget> createState() => _QuizIndexPage();
}

class _QuizIndexPage extends State<QuizIndexPage> {
  // method refresh
  void _refresh() => setState(() {});

  // method delete alert
  Future<void> _delMsg(Question data) async => showDialog<void>(
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
            'Apa kamu yakin ingin menghapus "${data.question}" dari daftar pertanyaan?',
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
                  bool deleted = await deleteData(data.id);

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
  Future<List<Question>> fetchData() async {
    try {
      final response = await http
          .get(Uri.https("cellaaudi.000webhostapp.com", "/question.php"));

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == 'Success') {
          List<Question> datas = List<Question>.from(
            json['data'].map((data) => Question.fromJson(data)),
          );

          return datas;
        } else {
          throw Exception("Gagal menampilkan data: ${json['message']}.");
        }
      } else {
        throw Exception(
            "Gagal menampilkan data: Status ${response.statusCode}.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: $e"),
        duration: Duration(seconds: 3),
      ));
      throw ("Terjadi kesalahan: $e");
    }
  }

  // method delete data
  Future<bool> deleteData(int que_id) async {
    try {
      bool deleted = false;

      final response = await http.post(
          Uri.https(
              "cellaaudi.000webhostapp.com", "/admin/question_delete.php"),
          body: {
            'que_id': que_id.toString(),
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
          print(json['message']);
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
  Widget tileData(Question data) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(
              "${data.sort}",
              style: GoogleFonts.nunito(),
            ),
          ),
          title: Text(
            data.question,
            style: GoogleFonts.nunito(fontSize: 16),
          ),
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setInt('id_que', data.id);

                  Navigator.pushNamed(context, 'que_detail');
                },
                icon: Icon(Icons.remove_red_eye_rounded),
                tooltip: "Lihat data",
                style: IconButton.styleFrom(foregroundColor: Colors.blue),
              ),
              IconButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setInt('id_que', data.id);
                  prefs.setInt('sort_que', data.sort);
                  prefs.setString('str_que', data.question);

                  Navigator.pushNamed(context, 'que_edit')
                      .then((value) => _refresh());
                },
                icon: Icon(Icons.edit_rounded),
                tooltip: "Perbarui data",
                style: IconButton.styleFrom(foregroundColor: Colors.orange),
              ),
              IconButton(
                onPressed: () => _delMsg(data).then((value) => _refresh()),
                icon: Icon(Icons.delete_rounded),
                tooltip: "Hapus data",
                style: IconButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ),
      );

  // method displayData
  Widget displayData() => FutureBuilder<List<Question>>(
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
            List<Question> datas = snapshot.data!;

            if (datas.isNotEmpty) {
              return Column(
                children: [
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
                          "Pertanyaan",
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
                  ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        Question data = datas[index];

                        return tileData(data);
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemCount: datas.length)
                ],
              );
            } else {
              return Center(
                child: Text(
                  'Data tidak ditemukan',
                  style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                ),
              );
            }
          } else {
            return Center(
              child: Text(
                'Data tidak ditemukan',
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
              ),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Data Kuis",
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          PopupMenuButton<String>(
              tooltip: "Lihat pilihan",
              onSelected: (value) {
                if (value == 'add') {
                  Navigator.pushNamed(context, 'que_add')
                      .then((value) => _refresh());
                } else {
                  Navigator.pushNamed(context, 'que_sort')
                      .then((value) => _refresh());
                }
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text(
                        'Tambah pertanyaan baru',
                        style: GoogleFonts.nunito(),
                      ),
                      value: 'add',
                    ),
                    PopupMenuItem(
                      child: Text(
                        'Ubah urutan pertanyaan',
                        style: GoogleFonts.nunito(),
                      ),
                      value: 'sort',
                    )
                  ]),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: displayData(),
          ),
        ),
      ),
    );
  }
}
