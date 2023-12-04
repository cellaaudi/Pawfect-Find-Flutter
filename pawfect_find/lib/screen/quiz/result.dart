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
  // // variable untuk quizUUID
  // String quizUUID = "";

  // variable untuk result quiz
  List<History> listHistory = [];

  // method untuk cek quiz_uuid
  Future<String> checkQuizUUID() async {
    final prefs = await SharedPreferences.getInstance();
    String quizUUID = prefs.getString("quiz_uuid") ?? '';
    return quizUUID;
  }

  // // method untuk fetch quiz_uuid
  // Future<void> getUUID() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String savedUUID = prefs.getString("quiz_uuid") ?? '';

  //   setState(() {
  //     quizUUID = savedUUID;
  //   });

  //   if (quizUUID.isNotEmpty) {
  //     fetchResult();
  //   } else {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Error')));
  //     throw Exception('Gagal mendapatkan hasil');
  //   }
  // }

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

  List<Widget> widResults() {
    List<Widget> temp = [];
    int i = 0;
    
    while (i < listHistory.length) {
      Widget w = Card(
        child: Text(listHistory[i].breed),
      );
      temp.add(w);
      i++;
    }

    return temp;
  }

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
        title: const Text('Hasil Rekomendasi'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
                'Berikut adalah rekomendasi ras anjing yang sesuai dengan jawaban kamu...'),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: widResults(),
            ),
            Divider(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}
