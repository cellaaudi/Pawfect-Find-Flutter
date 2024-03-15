import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/rule.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RuleDetailPage extends StatefulWidget {
  const RuleDetailPage({super.key});

  @override
  State<StatefulWidget> createState() => _RuleDetailPage();
}

class _RuleDetailPage extends State<RuleDetailPage> {
  // Shared pref
  int? idBreed;

  // method shared preferences id breed
  void getBreedID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idBreed = prefs.getInt('id_breed');
      print("id breed : $idBreed");
    });
  }

  Future<Rule> fetchData() async {
    try {
      final response = await http.post(
          Uri.parse(
              'http://localhost/ta/Pawfect-Find-PHP/admin/rule_detail.php'),
          body: {'id': idBreed.toString()});

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        Rule result = Rule.fromJson(json['data']);

        return result;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menampilkan data aturan ras anjing.'),
          duration: Duration(seconds: 3),
        ));

        throw Exception('Gagal menampilkan data aturan ras anjing.');
      }
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $ex'),
        duration: Duration(seconds: 3),
      ));

      throw Exception('Terjadi kesalahan: $ex');
    }
  }

  // method tile data
  Widget tileData(criterias) => ListTile(
        title: Text(
          criterias['criteria'],
          style: GoogleFonts.nunito(fontSize: 16),
        ),
      );

  // method build body
  Widget buildBody() => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: FutureBuilder<Rule>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.nunito(fontSize: 16),
                  ),
                );
              } else if (snapshot.hasData) {
                Rule rule = snapshot.data!;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          rule.breedName,
                          style: GoogleFonts.nunito(
                              fontSize: 24, fontWeight: FontWeight.w800),
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    // if (rule.criterias!.isNotEmpty)
                    //   for (var c in rule.criterias!) tileData(c)
                    // else
                    //   Center(
                    //     child: Text(
                    //       "Belum ada kriteria.",
                    //       style: GoogleFonts.nunito(
                    //           fontSize: 16.0, color: Colors.grey),
                    //     ),
                    //   )
                  ],
                );
              } else {
                return Center(
                  child: Text(
                    'Data tidak ditemukan.',
                    style: GoogleFonts.nunito(fontSize: 16),
                  ),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );

  @override
  void initState() {
    super.initState();

    getBreedID();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('id_breed');

                Navigator.pop(context);
              }),
          title: Text(
            'Detail Aturan',
            style:
                GoogleFonts.nunito(fontSize: 20.0, fontWeight: FontWeight.w800),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500), child: buildBody()),
        ),
      );
}
