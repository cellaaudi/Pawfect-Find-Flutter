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

  // method fetch data
  Future<List<Question>> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse("http://localhost/ta/Pawfect-Find-PHP/question.php"));

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        List<Question> datas = List<Question>.from(
          json['data'].map((data) => Question.fromJson(data)),
        );

        return datas;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Gagal menampilkan data pertanyaan."),
          duration: Duration(seconds: 3),
        ));
        throw ("Error: Gagal menampilkan data pertanyaan");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: $e"),
        duration: Duration(seconds: 3),
      ));
      throw ("Terjadi kesalahan: $e");
    }
  }

  // method tile data
  Widget tileData(Question data) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Text(
            "${data.sort}.",
            style: GoogleFonts.nunito(fontSize: 16),
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
                onPressed: () {},
                // onPressed: () => _delMsg(data).then((value) => _refresh()),
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
                  style: GoogleFonts.nunito(fontSize: 16),
                ),
              );
            }
          } else {
            return Center(
              child: Text(
                'Data tidak ditemukan',
                style: GoogleFonts.nunito(fontSize: 16),
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
