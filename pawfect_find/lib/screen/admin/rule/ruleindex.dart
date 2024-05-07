import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/rule.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RuleIndexPage extends StatefulWidget {
  const RuleIndexPage({super.key});

  @override
  State<StatefulWidget> createState() => _RuleIndexPage();
}

class _RuleIndexPage extends State<RuleIndexPage> {
  // method refresh
  void _refresh() => setState(() {});

  // method untuk ambil semua data
  Future<List<Rule>> fetchData() async {
    try {
      final response = await http.post(
          Uri.parse('http://localhost/ta/Pawfect-Find-PHP/admin/rule.php'));

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == "Success") {
          List<Rule> datas = List<Rule>.from(
            json['data'].map((data) => Rule.fromJson(data)),
          );

          return datas;
        } else {
          throw Exception("Gagal menampilkan data: ${json['message']}.");
        }
      } else {
        throw Exception(
            "Gagal menampilkan data: Status ${response.statusCode}.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: $e"),
        duration: Duration(seconds: 3),
      ));
      throw ("Terjadi kesalahan: $e");
    }
  }

  // method tile data
  Widget tileData(Rule data) => InkWell(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt('id_breed', data.breedId);
          prefs.setString('str_breed', data.breedName);

          Navigator.pushNamed(context, 'rule_detail')
              .then((value) => _refresh());
        },
        child: ListTile(
          title: Text(
            data.breedName,
            style: GoogleFonts.nunito(fontSize: 16),
          ),
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: data.totalCriterias == 0
                    ? Colors.red.shade100
                    : Colors.blue.shade100,
                child: Text(
                  data.totalCriterias.toString(),
                  style: GoogleFonts.nunito(),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Icon(Icons.arrow_forward_ios_rounded)
            ],
          ),
        ),
      );

  // method untuk display data
  Widget displayData() => FutureBuilder<List<Rule>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
              ),
            );
          } else if (snapshot.hasData) {
            List<Rule> datas = snapshot.data!;

            if (datas.isNotEmpty) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: ListTile(
                        title: Text(
                          "Ras Anjing",
                          style: GoogleFonts.nunito(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        trailing: Text(
                          "Total Kriteria",
                          style: GoogleFonts.nunito(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ))
                    ],
                  ),
                  Divider(),
                  ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        Rule data = datas[index];

                        return tileData(data);
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemCount: datas.length)
                ],
              );
            } else {
              return Center(
                child: Text(
                  'Data tidak ditemukan',
                  style: GoogleFonts.nunito(fontSize: 16),
                ),
              );
            }
          } else {
            return Center(
              child: Text(
                'Data tidak ditemukan',
                style: GoogleFonts.nunito(fontSize: 16),
              ),
            );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Data Aturan",
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: displayData(),
          ),
        ),
      ),
    );
  }
}
