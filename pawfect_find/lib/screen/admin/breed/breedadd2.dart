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
  // search
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // selected criteria
  List<Criteria> selected = [];

  // method untuk confirmation message sebelum keluar add breed
  void _backMessage() => showDialog<void>(
      context: context,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text(
            'Konfirmasi Keluar',
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
                onPressed: () => Navigator.popUntil(
                    context, ModalRoute.withName('breed_index')),
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

  // method untuk ambil semua data
  Future<List<Criteria>> fetchData() async {
    final response = await http.post(
        Uri.parse('http://localhost/ta/Pawfect-Find-PHP/admin/criteria.php'),
        body: {'search': _searchText});

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
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Criteria criteria = snapshot.data![index];
                  bool isSelected = selected.contains(criteria);

                  return CheckboxListTile(
                      title: Text(
                        criteria.criteria,
                        style: GoogleFonts.nunito(),
                      ),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            selected.add(criteria);
                          } else {
                            selected.remove(criteria);
                          }
                        });
                      });
                });
          } else {
            return Center(
              child: Text(
                'Tidak ada kriteria ditemukan',
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
              ),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      });

  // method body
  Widget buildBody() => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dapat memilih lebih dari 1 kriteria.",
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800, fontSize: 18.0),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Cari kriteria ...',
                          border: OutlineInputBorder(),
                        ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Expanded(child: checkbox())
              ],
            ),
          ),
        ),
      );

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
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
              // pas balek hapus shared pref selected
              onPressed: () => _backMessage(),
            ),
            title: Text(
              "Pilih Kriteria Ras Anjing",
              style:
                  GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
        ));
  }
}
