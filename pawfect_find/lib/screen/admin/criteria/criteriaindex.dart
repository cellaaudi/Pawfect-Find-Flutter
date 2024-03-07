import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/criteria.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CriteriaIndexPage extends StatefulWidget {
  const CriteriaIndexPage({super.key});

  @override
  State<StatefulWidget> createState() => _CriteriaIndexPage();
}

class _CriteriaIndexPage extends State<CriteriaIndexPage> {
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
      throw Exception("Gagal menampilkan data kriteria.");
    }
  }

  // method tile data
  Widget tileData(Criteria criteria) => InkWell(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt('id_criteria', criteria.id);

          Navigator.pushNamed(context, 'detail');
        },
        child: ListTile(
          leading: Text(
            criteria.id.toString(),
            style: GoogleFonts.nunito(fontSize: 16),
          ),
          title: Text(
            criteria.criteria,
            style:
                GoogleFonts.nunito(fontSize: 16),
          ),
        ),
      );

  // method untuk display data
  Widget displayData() => FutureBuilder<List<Criteria>>(
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
            List<Criteria> criterias = snapshot.data!;

            if (criterias.isNotEmpty) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: ListTile(
                        leading: Text(
                          "ID",
                          style: GoogleFonts.nunito(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        title: Text(
                          "Kriteria",
                          style: GoogleFonts.nunito(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ))
                    ],
                  ),
                  Divider(),
                  SizedBox(
                    height: 8,
                  ),
                  ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        Criteria criteria = criterias[index];

                        return tileData(criteria);
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemCount: criterias.length)
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
          "Data Kriteria",
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add_rounded),
            tooltip: "Tambah data baru",
          )
        ],
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
