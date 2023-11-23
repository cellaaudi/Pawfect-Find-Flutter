import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/question.dart';

class QuizPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QuizPage();
  }
}

class _QuizPage extends State<QuizPage> {
  List<Question> listQuestions = [];
  int currentPage = 0;
  Map<int, int?> selectedMap = {};

  Future<List<Question>> fetchQuestions() async {
    final response =
        await http.get(Uri.parse("http://localhost/ta/api/question.php"));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      List<Question> questions = List<Question>.from(json['data'].map((que) => Question.fromJson(que)));
      return questions;
      // return response.body;
    } else {
      throw Exception("Failed to read API");
    }
  }

  // readQuestions() {
  //   Future<String> data = fetchQuestions();
  //   data.then((value) {
  //     Map json = jsonDecode(value);
  //     for (var que in json['data']) {
  //       Question q = Question.fromJson(que);
  //       listQuestions.add(q);
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    fetchQuestions().then((questions) {
      setState(() {
        listQuestions = questions;
      });
    });
    // readQuestions();
  }

  Widget ListOfQuestions(Question question) {
    int? selected = selectedMap[question.id];

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          if (question.choices != null)
            Column(
              children: [
                for (var choice in question.choices!)
                  RadioListTile(
                    title: Text(choice['choice'].toString()),
                    value: choice['id'],
                    groupValue: selected,
                    onChanged: (value) {
                      setState(() {
                        selectedMap[question.id] = value;
                      });
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: listQuestions.length,
        onPageChanged: (int page) {
          setState(() {
            currentPage = page;
          });
        },
        itemBuilder: (BuildContext ctxt, int index) {
          return ListOfQuestions(listQuestions[index]);
        },
      ),
    );
  }
}
