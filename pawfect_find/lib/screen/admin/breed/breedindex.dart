import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/breed.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BreedIndexPage extends StatefulWidget {
  const BreedIndexPage({super.key});

  @override
  State<StatefulWidget> createState() => _BreedIndexPage();
}

class _BreedIndexPage extends State<BreedIndexPage> {
  // method refresh
  void _refresh() => setState(() {});

  // variable buat kata yang diketik user di search box
  String _searchText = '';

  // search otomatis
  TextEditingController _searchController = TextEditingController();

  // method untuk ambil semua data
  Future<List<Breed>> fetchData() async {
    final response = await http.post(
        Uri.parse('http://localhost/ta/Pawfect-Find-PHP/breed.php'),
        body: {'search': _searchText});

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);

      List<Breed> datas = List<Breed>.from(
        json['data'].map((data) => Breed.fromJson(data)),
      );

      return datas;
    } else {
      throw Exception("Gagal menampilkan data ras anjing.");
    }
  }

  // method tile data
  Widget tileData(Breed breed) => Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: FittedBox(
          fit: BoxFit.cover,
          child: Container(
              height: 128.0,
              width: 128.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  "http://localhost/ta/Pawfect-Find-PHP/${breed.imgAdult}",
                  fit: BoxFit.cover,
                ),
              )),
        ),
        title: Text(
          breed.breed,
          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        // trailing: Icon(Icons.arrow_forward_ios_rounded))),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setInt('id_breed', breed.id);

                Navigator.pushNamed(context, 'detail');
              },
              icon: Icon(Icons.remove_red_eye_rounded),
              tooltip: "Lihat data",
              style: IconButton.styleFrom(foregroundColor: Colors.blue),
            ),
            IconButton(
              onPressed: () async {
                // final prefs = await SharedPreferences.getInstance();
                // prefs.setInt('id_criteria', data.id);
                // prefs.setString('str_criteria', data.criteria);

                // Navigator.pushNamed(context, 'criteria_edit')
                //     .then((value) => _refresh());
              },
              icon: Icon(Icons.edit_rounded),
              tooltip: "Perbarui data",
              style: IconButton.styleFrom(foregroundColor: Colors.orange),
            ),
            IconButton(
              onPressed: () {},
              // onPressed: () => _delMsg(data).then((value) => _refresh()),
              icon: Icon(Icons.delete_rounded),
              tooltip: "Hapus data",
              style: IconButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ));

  // method untuk display data
  Widget displayData() => FutureBuilder<List<Breed>>(
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
            List<Breed> breeds = snapshot.data!;

            if (breeds.isNotEmpty) {
              return ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Breed breed = breeds[index];

                    return tileData(breed);
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: breeds.length);
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

  // method build body
  Widget buildBody() => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                  child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Cari ras anjing ...',
                    border: OutlineInputBorder()),
              )),
            ]),
            SizedBox(height: 16),
            displayData()
          ],
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

    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Data Ras Anjing",
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, 'breed_add')
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
          child: buildBody(),
        ),
      ),
    );
  }
}
