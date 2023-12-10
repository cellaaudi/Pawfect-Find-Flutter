import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/breed.dart';

class BreedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BreedPage();
}

class _BreedPage extends State<BreedPage> {
  Future<List<Breed>> fetchBreeds(String search) async {
    final response = await http.post(
        Uri.parse('http://localhost/ta/Pawfect-Find-PHP/breed.php'),
        body: {'search': search});

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);

      // if (json['result'] == 'Success') {
      List<Breed> breeds =
          List<Breed>.from(json['data'].map((breed) => Breed.fromJson(breed)));

      return breeds;
      // }
    } else {
      throw Exception("Failed to read API");
    }
  }

  Widget displayBody() => Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        padding: EdgeInsets.all(16.0),
        children: [Text('Test')],
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 80.0,
          flexibleSpace: Padding(
              padding: EdgeInsets.all(16.0),
              child: SearchBar(
                leading: Icon(Icons.search_rounded),
                hintText: 'Cari',
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shadowColor: MaterialStateProperty.all(Colors.grey.shade50),
                elevation: MaterialStateProperty.all(8.0),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0))),
              ))),
    );
  }
}
