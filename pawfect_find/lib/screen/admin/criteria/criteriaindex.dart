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
  // method refresh
  void _refresh() => setState(() {});

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
  Widget tileData(Criteria data) => ListTile(
        leading: Text(
          data.id.toString(),
          style: GoogleFonts.nunito(fontSize: 16),
        ),
        title: Text(
          data.criteria,
          style: GoogleFonts.nunito(fontSize: 16),
        ),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setInt('id_criteria', data.id);
                prefs.setString('str_criteria', data.criteria);

                Navigator.pushNamed(context, 'criteria_edit')
                    .then((value) => _refresh());
              },
              icon: Icon(Icons.edit_rounded),
              tooltip: "Perbarui data",
              style: IconButton.styleFrom(foregroundColor: Colors.blue),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.delete_rounded),
              tooltip: "Hapus data",
              style: IconButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
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
            List<Criteria> datas = snapshot.data!;

            if (datas.isNotEmpty) {
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
                        trailing: Text(
                          "Aksi",
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
                        Criteria data = datas[index];

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
          "Data Kriteria",
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, 'criteria_add')
                .then((value) => _refresh()),
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
