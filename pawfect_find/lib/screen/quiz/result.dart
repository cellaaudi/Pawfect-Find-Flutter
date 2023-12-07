import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ResultPage();
  }
}

class _ResultPage extends State<ResultPage> {
  // variable untuk result quiz
  List<History> listHistory = [];

  // method untuk cek quiz_uuid
  Future<String> checkQuizUUID() async {
    final prefs = await SharedPreferences.getInstance();
    String quizUUID = prefs.getString("quiz_uuid") ?? '';
    return quizUUID;
  }

  // method untuk fetch result dari table histories di db
  Future<List<History>> fetchResult(String uuid) async {
    final response = await http.post(
        Uri.parse("http://localhost/ta/Pawfect-Find-PHP/result.php"),
        body: {'uuid': uuid});

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      List<History> result = List<History>.from(
          json['data'].map((hist) => History.fromJson(hist)));
      return result;
    } else {
      throw Exception("Failed to read API");
    }
  }

  // method untuk display list tile hasil rekomendasi
  Widget displayResult() => SingleChildScrollView(
    padding: EdgeInsets.all(16.0),
    child: Column(
      children: [
        Text('Berikut adalah rekomendasi ras anjing yang sesuai dengan jawaban kamu...'),
        SizedBox(height: 32.0,),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: listHistory.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Card(
              child: ListTile(
                title: Text(listHistory[index].breed),
                trailing: Text("${listHistory[index].cf.toStringAsFixed(2)}%"),
              ),
            );
          },
        ),
      ],
    ),
  );

  @override
  void initState() {
    super.initState();
    // getUUID();
    checkQuizUUID().then((uuid) {
      if (uuid != '') {
        fetchResult(uuid).then((results) {
          setState(() {
            listHistory = results;
          });
        });
      } else {
        throw Exception('Gagal mendapatkan hasil');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios_new_rounded),
        title: const Text('Hasil Rekomendasi'),
      ),
      body: displayResult(),
    );
  }
}
