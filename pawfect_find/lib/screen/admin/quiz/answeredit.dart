import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/choice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnswerEditPage extends StatefulWidget {
  const AnswerEditPage({super.key});

  @override
  State<StatefulWidget> createState() => _AnswerAddPage();
}

class _AnswerAddPage extends State<AnswerEditPage> {
  // shared pref
  int? idChoice;

  // controller
  TextEditingController _choiceController = TextEditingController();

  // method shared preferences id breed
  void getChoiceID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idChoice = prefs.getInt('id_choice');
    });
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
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.remove('id_choice');

                  Navigator.popUntil(
                      context, ModalRoute.withName('que_detail'));
                },
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
  Future<Choice> fetchData() async {
    try {
      final response = await http.post(Uri.parse('http://localhost/ta/Pawfect-Find-PHP/admin/criteria.php'));
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $ex'),
        duration: Duration(seconds: 3),
      ));
      throw Exception('Terjadi kesalahan: $ex');
    }
  }

  // method build body
  Widget buildBody() => idChoice == null
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
                "Pertanyaan",
                style: GoogleFonts.nunito(fontSize: 12.0),
              ),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 48,
              ),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            "Simpan Perubahan",
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

    getChoiceID();
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
            "Perbarui Pilihan Jawaban",
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
