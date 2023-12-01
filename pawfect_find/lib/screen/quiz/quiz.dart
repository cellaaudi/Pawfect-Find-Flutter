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
  // list untuk menampung pertanyaan dari database
  List<Question> listQuestions = [];

  // variable untuk menentukan sampai di pertanyaan halaman berapa user saat itu
  int currentPage = 0;

  // map untuk rdo
  Map<int, int?> selectedMap = {};

  // list untuk menampung jawaban user dari setiap pertanyaan
  List<Answer> userAnswers = [];

  // map untuk cek setidaknya 1 rdo telah dipilih sebelum lanjut ke halaman selanjutnya
  Map<int, bool?> isRadioSelected = {};

  // method untuk fetch questions dari db
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

  // method untuk kirim post jawaban user ke api
  void postAnswers(List<Answer> answers) async {
    final response = await http.post(
        Uri.parse("http://localhost/ta/Pawfect-Find-PHP/answer.php"),
        body: {'answers': jsonEncode(answers)});

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);
      Navigator.pushNamed(context, "result", arguments: result);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
      throw Exception('Gagal mendapatkan hasil');
    }
  }

  // skala linear cf
  String cfLabel(double cf) {
    switch (cf.toDouble()) {
      case 0:
        return 'Sangat tidak yakin';
      case 0.25:
        return 'Tidak yakin';
      case 0.5:
        return 'Cukup yakin';
      case 0.75:
        return 'Yakin';
      case 1:
        return 'Sangat yakin';
      default:
        return '';
    }
  }

  // UI quiz
  Widget ListOfQuestions(Question question, int index) {
    int? selected = selectedMap[question.id];

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                question.question,
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 8.0),
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
                  ],
                ),
              const SizedBox(height: 32.0),
              const Text('Seberapa yakin Anda atas jawaban Anda?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sangat tidak yakin',
                    style: TextStyle(fontSize: 12.0),
                  ),
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
                  const Text('Sangat yakin',
                  style: TextStyle(fontSize: 12.0),),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                  Expanded(
                    child: 
                    OutlinedButton(
                      onPressed: () {
                        // hapus data yang sudah masuk pada list saat button "Kembali" diklik
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
                      child: const Text('Kembali'),
                    ),
                  )
                  else
                  const Expanded(child: SizedBox.shrink()),
                  // jarak antara button "Kembali" dan "Berikutnya"
                  const SizedBox(width: 8.0),
                  Expanded(
                      child: ElevatedButton(
                    // periksa apakah user sudah memilih 1 jawaban
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
                            }
                          }
                        // button "Berikutnya" tidak bisa diklik karena user belum memilih jawaban
                        : null,
                    child: Text(
                        // inline if untuk ganti teks di button tergantung halaman berapa
                        index < listQuestions.length - 1
                            ? 'Berikutnya'
                            : 'Selesai'),
                  ))
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

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
