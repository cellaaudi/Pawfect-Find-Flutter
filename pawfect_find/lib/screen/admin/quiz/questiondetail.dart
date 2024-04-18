import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/question.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionDetailPage extends StatefulWidget {
  const QuestionDetailPage({super.key});

  @override
  State<StatefulWidget> createState() => _QuestionDetailPage();
}

class _QuestionDetailPage extends State<QuestionDetailPage> {
  // method refresh
  void _refresh() => setState(() {});

  // shared pref
  int? idQue;
  String? strQue;

  // method shared preferences id breed
  void getQueID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idQue = prefs.getInt('id_que');
    });
  }

  // method fetch data
  Future<Question> fetchData() async {
    try {
      final response = await http.post(
          Uri.parse(
              "http://localhost/ta/Pawfect-Find-PHP/admin/question_detail.php"),
          body: {
            'id': idQue.toString(),
          });

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == "Success") {
          Question result = Question.fromJson(json['data']);

          final prefs = await SharedPreferences.getInstance();
          prefs.setString('str_que', result.question);

          return result;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Gagal menampilkan data pertanyaan: ${json['message']}."),
            duration: Duration(seconds: 3),
          ));

          throw Exception(
              "Gagal menampilkan data pertanyaan: ${json['message']}.");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menampilkan data pertanyaan.'),
          duration: Duration(seconds: 3),
        ));

        throw Exception('Gagal menampilkan data pertanyaan.');
      }
    } catch (ex) {
      throw Exception("Terjadi kesalahan: $ex");
    }
  }

  // method string
  Widget txtQue(String title, String val) => Column(
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

  // method tile data
  Widget tileData(var choice) => Card(
      elevation: 8,
      color: Colors.white,
      shadowColor: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: ListTile(
          title: Text(
            choice['choice'],
            style:
                GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: choice['criteria'] != null
              ? Text(
                  "Kriteria: ${choice['criteria']}",
                  style: GoogleFonts.nunito(),
                )
              : Text(
                  "Kriteria: -",
                  style: GoogleFonts.nunito(),
                ),
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setInt('id_choice', choice['choice_id']);

                  Navigator.pushNamed(context, 'ans_edit');
                },
                icon: Icon(Icons.edit_rounded),
                tooltip: "Perbarui data",
                style: IconButton.styleFrom(foregroundColor: Colors.orange),
              ),
              IconButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setInt('id_choice', choice['choice_id']);

                  // Navigator.pushNamed(context, 'que_detail');
                },
                icon: Icon(Icons.delete_rounded),
                tooltip: "Hapus data",
                style: IconButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ));

  // method build body
  Widget buildBody() => idQue == null
      ? Center(
          child: CircularProgressIndicator(),
        )
      : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: FutureBuilder<Question>(
              future: fetchData(),
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
                    Question data = snapshot.data!;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        txtQue("No. Urut", data.sort.toString()),
                        txtQue("Pertanyaan", data.question),
                        Text(
                          "Pilihan Jawaban",
                          style: GoogleFonts.nunito(fontSize: 12),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: data.choices!.length,
                            itemBuilder: (context, index) {
                              var choice = data.choices![index];

                              return tileData(choice);
                            }),
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: OutlinedButton.icon(
                                    onPressed: () =>
                                        Navigator.pushNamed(context, 'ans_add')
                                            .then((value) => _refresh()),
                                    icon: Icon(Icons.add_rounded),
                                    label: Text(
                                      "Tambah Pilihan Jawaban",
                                      style: GoogleFonts.nunito(),
                                    )))
                          ],
                        )
                      ],
                    );
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
                  return Center(child: CircularProgressIndicator());
                }
              }),
        );

  @override
  void initState() {
    super.initState();

    getQueID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: "Kembali",
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.remove('id_que');

            Navigator.pop(context);
          },
        ),
        title: Text(
          "Detail Pertanyaan",
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500), child: buildBody()),
      ),
    );
  }
}
