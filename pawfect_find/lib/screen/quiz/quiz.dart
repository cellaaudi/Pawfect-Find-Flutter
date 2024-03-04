import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawfect_find/class/answer.dart';
import 'package:pawfect_find/class/question.dart';

class QuizPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QuizPage();
}

class _QuizPage extends State<QuizPage> {
  // Shared Preferences
  int? idUser;

  // method shared preferences role
  void getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idUser = prefs.getInt('id_user') ?? 0;
    });
  }

  // variable untuk menentukan sampai di pertanyaan halaman berapa user saat itu
  int currentPage = 0;

  // list untuk menampung pertanyaan dari database
  List<Question> listQuestions = [];

  // list untuk menampung jawaban user dari setiap pertanyaan
  List<Answer> userAnswers = [];

  // map untuk rdo
  Map<int, int?> selectedMap = {};

  // map untuk cek setidaknya 1 rdo telah dipilih sebelum lanjut ke halaman selanjutnya
  Map<int, bool?> isRadioSelected = {};

  // map untuk nilai dari cf
  Map<int, double> cfValues = {};

  // late inisialisation untuk page controller
  late PageController _pageController;

  // progress bar
  double progress = 0.0;

  // method untuk confirmation message sebelum keluar quiz
  void _backMessage() {
    showDialog<void>(
        context: context,
        builder: (BuildContext ctxt) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            title: Text(
              'Konfirmasi Keluar',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Jika kamu keluar, maka jawaban kamu akan hilang.',
              style: GoogleFonts.nunito(fontSize: 16.0),
            ),
            actions: <Widget>[
              TextButton(
                  style: TextButton.styleFrom(
                      textStyle:
                          GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.nunito(),
                  )),
              TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      textStyle:
                          GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                  child: Text(
                    'Keluar',
                    style: GoogleFonts.nunito(),
                  ))
            ],
          );
        });
  }

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
        body: {
          'answersJson': jsonEncode(answers),
          'user_id': idUser.toString()
        });

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);

      if (result['result'] == 'Success') {
        String historyId = result['history_id'].toString();

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('history_id', historyId);

        Navigator.pushNamed(context, "result");
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
      throw Exception('Gagal mendapatkan hasil');
    }
  }

  // method untuk label skala linear cf
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

  // progress bar
  void updateProgress(int currentIndex, int totalQuestions) {
    setState(() {
      progress = (currentIndex + 1) / totalQuestions;
    });
  }

  // method untuk build UI quiz
  Widget displayQuestions(Question question, int index) {
    int? selected = selectedMap[question.id];

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                question.question,
                style: GoogleFonts.nunito(fontSize: 18.0),
              ),
              const SizedBox(height: 8.0),
              if (question.choices != null)
                Column(
                  children: [
                    for (var choice in question.choices!)
                      RadioListTile(
                        title: Text(
                          choice['choice'].toString(),
                          style: GoogleFonts.nunito(fontSize: 16.0),
                        ),
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
              const SizedBox(height: 48.0),
              Text(
                'Seberapa yakin kamu atas jawabanmu?',
                style: GoogleFonts.nunito(fontSize: 16.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sangat tidak yakin',
                    style: GoogleFonts.nunito(fontSize: 12.0),
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
                  Text(
                    'Sangat yakin',
                    style: GoogleFonts.nunito(fontSize: 12.0),
                  ),
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
                      child: OutlinedButton(
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
                        child: Text(
                          'Kembali',
                          style: GoogleFonts.nunito(fontSize: 16.0),
                        ),
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
                          : 'Selesai',
                      style: GoogleFonts.nunito(fontSize: 16.0),
                    ),
                  ))
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserID();

    // inisialisation untuk page controller
    _pageController = PageController();
    fetchQuestions().then((questions) {
      setState(() {
        listQuestions = questions;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
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
              'Kuis Pawfect Find',
              style: GoogleFonts.nunito(
                  fontSize: 20.0, fontWeight: FontWeight.w800),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: PageView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  itemCount: listQuestions.length,
                  onPageChanged: (int page) {
                    setState(() {
                      currentPage = page;
                    });
                    updateProgress(page, listQuestions.length);
                  },
                  itemBuilder: (BuildContext ctxt, int index) {
                    return displayQuestions(listQuestions[index], index);
                  },
                ),
              ),
              Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${currentPage + 1} dari ${listQuestions.length} pertanyaan',
                          style: GoogleFonts.nunito(fontSize: 16.0),
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.0),
                            bottom: Radius.circular(16.0)),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                    ],
                  )),
            ],
          )),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
