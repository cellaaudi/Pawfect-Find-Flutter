import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/criteria.dart';

class BreedAdd2Page extends StatefulWidget {
  const BreedAdd2Page({super.key});

  @override
  State<StatefulWidget> createState() => _BreedAdd2Page();
}

class _BreedAdd2Page extends State<BreedAdd2Page> {
  // method untuk ambil semua data
  Future<List<Criteria>> fetchData() async {
    final response = await http.post(
        Uri.parse('http://localhost/ta/Pawfect-Find-PHP/admin/criteria.php'));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);

      List<Criteria> datas = List<Criteria>.from(
        json['data'].map((data) => Criteria.fromJson(data)),
      );

      return datas;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal menampilkan data kriteria."),
        duration: Duration(seconds: 3),
      ));
      throw Exception("Gagal menampilkan data kriteria.");
    }
  }

  // method checkbox
  Widget checkbox() => FutureBuilder<List<Criteria>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
              ),
            );
          } else if (snapshot.hasData) {
            List<Criteria> criterias = snapshot.data!;

            return CheckboxListTile(value: value, onChanged: onChanged)
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          // pas balek hapus shared pref selected
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Pilih Kriteria Ras Anjing",
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
