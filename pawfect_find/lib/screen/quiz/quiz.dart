import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuizPage extends StatefulWidget {
  @override
  State<QuizPage> createState() => _QuizPage();
}

class _QuizPage extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: <Widget>[],),
    );
  }
}

String _temp = "waiting API respond...";
Future<String> fetchData() async {
  final response = await http.get(Uri.parse("http://localhost:4000/question"));

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception("Failed to read API");
  }
}