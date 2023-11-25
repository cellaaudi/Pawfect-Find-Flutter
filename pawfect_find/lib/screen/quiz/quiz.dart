import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/answer.dart';
import 'package:pawfect_find/class/question.dart';

class QuizPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QuizPage();
  }
}

class _QuizPage extends State<QuizPage> {
  double margin = 0;

  List<Question> listQuestions = [];
  int currentPage = 0;
  Map<int, int?> selectedMap = {};

  List<Answer> userAnswers = [];

  Map<int, bool?> isRadioSelected = {};

  // GET QUESTIONS AND THEIR CHOICES FROM DB
  Future<List<Question>> fetchQuestions() async {
    final response = await http
        .get(Uri.parse("http://localhost/ta/Pawfect-Find-PHP/question.php"));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      List<Question> questions = List<Question>.from(
          json['data'].map((que) => Question.fromJson(que)));
      return questions;
    } else {
      throw Exception("Failed to read API");
    }
  }

  // POST USER ANSWERS
  void postAnswers(List<Answer> answers) async {
    final response = await http.post(
        Uri.parse("http://localhost/ta/Pawfect-Find-PHP/answer.php"),
        body: {'answers': jsonEncode(answers)});

    debugPrint(response.body);
    // if (response.statusCode == 200) {
    //   Map<String, dynamic> result = jsonDecode(response.body);
    //   Navigator.pushNamed(context, "result", arguments: result);
    // } else {
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(SnackBar(content: Text('Error')));
    //   throw Exception('Failed to read API');
    // }
  }

  // LINEAR SCALE CF
  String cfLabel(double cf) {
    switch (cf.toDouble()) {
      case 0:
        return 'Sangat Tidak Yakin';
      case 0.25:
        return 'Tidak Yakin';
      case 0.5:
        return 'Cukup Yakin';
      case 0.75:
        return 'Yakin';
      case 1:
        return 'Sangat Yakin';
      default:
        return '';
    }
  }

  // BUILD THE UI FOR QUIZ
  Widget ListOfQuestions(Question question, int index) {
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
                        isRadioSelected[question.id] = true;
                      });
                    },
                  ),
                Text('Seberapa yakin Anda atas jawaban Anda?'),
                Slider(
                  value: cfValues[question.id] ?? 0.0,
                  onChanged: (value) {
                    setState(() {
                      cfValues[question.id] = value;
                    });
                  },
                  min: 0.0,
                  max: 1.0,
                  divisions: 4,
                  label: cfLabel(cfValues[question.id] ?? 0.0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sangat Tidak Yakin'),
                    Text('Sangat Yakin'),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Hapus data saat tombol "Back" diklik
                    if (index > 0) {
                      setState(() {
                        selectedMap.remove(question.id);
                        isRadioSelected.remove(question.id);
                        cfValues.remove(question.id);
                        userAnswers.removeWhere(
                            (answer) => answer.questionId == question.id);
                      });
                      _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  },
                  child: Text('Back'),
                ),
                ElevatedButton(
                  // Periksa apakah user sudah memilih 1 jawaban
                  onPressed: (isRadioSelected[question.id] ?? false)
                      ? () {
                          if (selectedMap.containsKey(question.id)) {
                            setState(() {
                              userAnswers.add(Answer(
                                  questionId: question.id,
                                  choiceId: selectedMap[question.id]!,
                                  cf: cfValues[question.id] ?? 0.0));
                            });
                          }
                          if (index < listQuestions.length - 1) {
                            _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          } else {
                            postAnswers(userAnswers);
                            // for (var answer in userAnswers) {
                            //   debugPrint(answer.toString());
                            // }
                          }
                        }
                      // Button Next tidak bisa diklik karena user belum memilih jawaban
                      : null,
                  child: Text(
                      index < listQuestions.length - 1 ? 'Next' : 'Submit'),
                )
              ],
            ),
        ],
      ),
    );
  }

  // PAGE VIEW CONTROLLER LATE VAR
  late PageController _pageController;
  Map<int, double> cfValues = {};

  @override
  void initState() {
    super.initState();
    // PAGE VIEW CONTROLLER INITIALISATION
    _pageController = PageController();
    fetchQuestions().then((questions) {
      setState(() {
        listQuestions = questions;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        itemCount: listQuestions.length,
        onPageChanged: (int page) {
          setState(() {
            currentPage = page;
          });
        },
        itemBuilder: (BuildContext ctxt, int index) {
          return ListOfQuestions(listQuestions[index], index);
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
