import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/criteria.dart';

class QuestionAddPage extends StatefulWidget {
  const QuestionAddPage({super.key});

  @override
  State<StatefulWidget> createState() => _QuestionAddPage();
}

class _QuestionAddPage extends State<QuestionAddPage> {
  // next sort
  int sort = 0;

  // controller
  TextEditingController _queController = TextEditingController();
  List<TextEditingController> _ansController = [];

  // add/remove field
  void addField() {
    setState(() {
      _ansController.add(TextEditingController());
      selCrits.add(0);
    });
  }

  void removeField(int index) {
    setState(() {
      _ansController.removeAt(index);
      selCrits.removeAt(index);
    });
  }

  // dropdown handler
  List<int> selCrits = [];

  // disable save
  bool isFilled() {
    if (_queController.text.isEmpty) return false;

    for (var cont in _ansController) {
      if (cont.text.isEmpty) return false;
    }

    return true;
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
                    context, ModalRoute.withName('quiz_index')),
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

  // get next sort
  Future<void> getNext() async {
    try {
      final response = await http.get(Uri.parse(
          "http://localhost/ta/Pawfect-Find-PHP/admin/question_sort.php"));

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == 'Success') {
          setState(() {
            sort = json['data'];
          });
        } else {
          throw Exception(
              'Gagal menampilkan nomor urut selanjutnya: ${json['result']}');
        }
      } else {
        throw Exception('Gagal menampilkan nomor urut selanjutnya.');
      }
    } catch (ex) {
      throw Exception("Terjadi kesalahan: $ex");
    }
  }

  // get criterias
  Future<List<Criteria>> fetchCriterias() async {
    final response = await http.post(
        Uri.parse('http://localhost/ta/Pawfect-Find-PHP/admin/criteria.php'));

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

  // // add new data
  Future<void> addData() async {
    if (isFilled()) {
      try {
        List<String> choices =
            _ansController.map((controller) => controller.text).toList();

        final response = await http.post(
            Uri.parse(
                'http://localhost/ta/Pawfect-Find-PHP/admin/question_add.php'),
            body: {
              'sort': sort.toString(),
              'question': _queController.text,
              'choices': jsonEncode(choices),
              'criterias': jsonEncode(selCrits)
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Gagal menambahkan data baru: ${json['message']}"),
              duration: Duration(seconds: 3),
            ));
            throw Exception("Gagal menambahkan data baru.");
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Gagal menambahkan data baru."),
            duration: Duration(seconds: 3),
          ));
          throw Exception("Gagal menambahkan data baru.");
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
      throw Exception("Data belum semua terisi.");
    }
  }

  // method choice
  Widget cardChoice(int index) => FutureBuilder<List<Criteria>>(
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

            return Expanded(
                child: Card(
              child: Column(
                children: [
                  TextField(
                    maxLines: null,
                    controller: _ansController[index],
                    decoration: InputDecoration(
                        hintText: "Contoh: Hitam",
                        border: OutlineInputBorder()),
                  ),
                  DropdownButtonFormField<int>(
                    // value: ,
                    value: selCrits[index],
                    items: criterias.map((crit) {
                      return DropdownMenuItem(
                          value: crit.id, child: Text(crit.criteria));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selCrits[index] = value!;
                      });
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(8)),
                  )
                ],
              ),
            ));
          } else {
            return Center(
              child: Text(
                'Gagal memuat. Silahkan coba lagi.',
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
  Widget buildBody() => sort == 0
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
                sort.toString(),
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
                  cardChoice(0),
                ],
              ),
              Column(
                  children: List.generate(_ansController.length - 1, (index) {
                return Row(
                  children: [
                    cardChoice(index + 1),
                    if (index + 1 == 1)
                      IconButton(
                        onPressed: addField,
                        icon: Icon(
                          Icons.add_rounded,
                          color: Colors.blue,
                        ),
                        tooltip: "Tambah pilihan jawaban",
                      ),
                    if (index + 1 > 1)
                      IconButton(
                        onPressed: () => removeField(index + 1),
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.red,
                        ),
                        tooltip: "Hapus pilihan jawaban",
                      ),
                  ],
                );
              })),
              SizedBox(
                height: 48,
              ),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () => addData(),
                          child: Text(
                            "Simpan Pertanyaan Baru",
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

    getNext();

    if (_ansController.length < 2) {
      _ansController.add(TextEditingController());
      _ansController.add(TextEditingController());
    }

    selCrits = List.generate(_ansController.length, (index) => 0);
  }

  @override
  void dispose() {
    for (var cont in _ansController) {
      cont.dispose();
    }

    super.dispose();
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
            "Tambah Pertanyaan",
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
