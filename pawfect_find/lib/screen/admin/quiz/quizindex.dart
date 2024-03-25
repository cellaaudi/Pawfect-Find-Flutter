import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/question.dart';

class QuizIndexPage extends StatefulWidget {
  const QuizIndexPage({super.key});

  @override
  State<StatefulWidget> createState() => _QuizIndexPage();
}

class _QuizIndexPage extends State<QuizIndexPage> {
  // method refresh
  void _refresh() => setState(() {});

  // method popup menu
  void handleMenu(String menu) {
    switch (menu) {
      case 'Tambah pertanyaan baru':
        break;
      case 'Ubah urutan pertanyaan':
        break;
    }
  }

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
              onSelected: handleMenu,
              itemBuilder: (context) {
                return {'Tambah pertanyaan baru', 'Ubah urutan pertanyaan'}
                    .map((menu) => PopupMenuItem<String>(child: Text(menu)))
                    .toList();
              }),
        ],
      ),
    );
  }
}
