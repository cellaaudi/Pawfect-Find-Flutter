import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/question.dart';

class QuestionSortPage extends StatefulWidget {
  const QuestionSortPage({super.key});

  @override
  State<StatefulWidget> createState() => _QuestionSortPage();
}

class _QuestionSortPage extends State<QuestionSortPage> {
  // var reorder
  List<Question> queList = [];
  GlobalKey<ReorderableListState> _listKey = GlobalKey();

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

  // method fetch data
  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse("http://localhost/ta/Pawfect-Find-PHP/question.php"));

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        List<Question> datas = List<Question>.from(
          json['data'].map((data) => Question.fromJson(data)),
        );

        setState(() {
          queList = datas;
        });
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

  // mwthod save new order
  Future<void> updateOrder() async {
    try {
      List<Map<String, dynamic>> newOrder = [];

      for (int i = 0; i < queList.length; i++) {
        newOrder.add({
          'id': queList[i].id,
          'sort': i + 1,
        });
      }

      final response = await http.post(
          Uri.parse(
              "http://localhost/ta/Pawfect-Find-PHP/admin/question_edit_sort.php"),
          body: {
            'newOrder': jsonEncode(newOrder),
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
        throw Exception("Gagal memperbarui data: ${response.statusCode}");
      }
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: $ex"),
        duration: Duration(seconds: 3),
      ));
      throw Exception("Terjadi kesalahan: $ex");
    }
  }

  // method on reorder
  void _onReorder(int oldId, int newId) {
    setState(() {
      if (oldId < newId) newId--;

      final Question que = queList.removeAt(oldId);
      queList.insert(newId, que);
    });
  }

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  // method build body
  Widget buildBody() => queList.isEmpty
      ? Center(child: CircularProgressIndicator())
      : ReorderableListView.builder(
          padding: EdgeInsets.all(16),
          key: _listKey,
          itemBuilder: (context, index) {
            var question = queList[index];

            return ReorderableDragStartListener(
                key: ValueKey(question.id),
                index: index,
                child: ListTile(
                  leading: CircleAvatar(
                      child: Text(
                    "${index + 1}.",
                    style: GoogleFonts.nunito(fontSize: 16),
                  )),
                  title: Text(question.question),
                ));
          },
          itemCount: queList.length,
          onReorder: _onReorder,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          buildDefaultDragHandles: false,
        );

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          _backMessage;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => _backMessage(),
            ),
            title: Text(
              "Ubah Urutan Pertanyaan",
              style:
                  GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                onPressed: () => updateOrder(),
                icon: Icon(Icons.check_rounded),
                color: Colors.blue,
                tooltip: "Simpan perubahan",
              )
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Tahan dan geser pertanyaan untuk mengubah urutannya.",
                        style: GoogleFonts.nunito(fontSize: 16),
                      ),
                    ),
                    Divider(),
                    Expanded(child: buildBody()),
                  ],
                )),
          ),
        ));
  }
}
