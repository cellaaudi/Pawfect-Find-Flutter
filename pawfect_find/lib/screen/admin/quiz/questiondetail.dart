import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionDetailPage extends StatefulWidget {
  const QuestionDetailPage({super.key});

  @override
  State<StatefulWidget> createState() => _QuestionDetailPage();
}

class _QuestionDetailPage extends State<QuestionDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: "Kembali",
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.remove('id_que');

            Navigator.pop(context);
          },
        ),
        title: Text(
          "Detail Pertanyaan",
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
