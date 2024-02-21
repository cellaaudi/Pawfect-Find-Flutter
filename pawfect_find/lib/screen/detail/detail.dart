import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/breed.dart';

class DetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  // method untuk ambil data breed dari database
  // Future<Breed> fetchBreed() async {
  //   final response = await http.get(
  //     Uri.parse("http://localhost/ta/Pawfect-Find-PHP/breed/detail.php"),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios_new_rounded),
        title: const Text('Detail'),
      ),
    );
  }
}