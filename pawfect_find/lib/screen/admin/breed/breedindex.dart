import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pawfect_find/class/breed.dart';
import 'package:pawfect_find/screen/detail/detail.dart';
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

  // method delete alert
  Future<void> _delMsg(Breed data) async => showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text(
            'Hapus Ras Anjing',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apa kamu yakin ingin menghapus "${data.breed}" dari daftar Ras Anjing?',
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
                onPressed: () async {
                  bool deleted = await deleteData(data);

                  if (deleted) {
                    Navigator.pop(context);
                  }
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
                child: Text(
                  'Hapus',
                  style: GoogleFonts.nunito(),
                ))
          ],
        );
      });

  // method delete foto lama di firebase
  Future<void> deleteFirebaseImg(String imgUrl) async {
    try {
      if (imgUrl.isNotEmpty) {
        Reference ref = FirebaseStorage.instance.refFromURL(imgUrl);
        await ref.delete();
      }
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: $ex."),
        duration: Duration(seconds: 3),
      ));
      throw Exception("Terjadi kesalahan: $ex.");
    }
  }

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

  // method delete data
  Future<bool> deleteData(Breed data) async {
    try {
      bool deleted = false;

      await deleteFirebaseImg(data.imgPuppy);
      await deleteFirebaseImg(data.imgAdult);

      final response = await http.post(
          Uri.parse(
              "http://localhost/ta/Pawfect-Find-PHP/admin/breed_delete.php"),
          body: {
            'breed_id': data.id.toString(),
          });

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == 'Success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Berhasil hapus data."),
            duration: Duration(seconds: 3),
          ));

          deleted = true;
        } else {
          print(json['message']);
          throw Exception("Gagal hapus data: ${json['message']}.");
        }
      } else {
        throw Exception("Gagal hapus data: Status ${response.statusCode}.");
      }

      return deleted;
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $ex'),
        duration: Duration(seconds: 3),
      ));

      throw Exception('Terjadi kesalahan: $ex');
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
                  breed.imgAdult,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, trace) {
                    return Image.asset(
                      "assets/logos/logo-black.png",
                      fit: BoxFit.cover,
                    );
                  },
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

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailPage(
                              fromRec: false,
                            )));
              },
              icon: Icon(Icons.remove_red_eye_rounded),
              tooltip: "Lihat data",
              style: IconButton.styleFrom(foregroundColor: Colors.blue),
            ),
            IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setInt('id_breed', breed.id);

                Navigator.pushNamed(context, 'breed_edit')
                    .then((value) => _refresh());
              },
              icon: Icon(Icons.edit_rounded),
              tooltip: "Perbarui data",
              style: IconButton.styleFrom(foregroundColor: Colors.orange),
            ),
            IconButton(
              onPressed: () => _delMsg(breed).then((value) => _refresh()),
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
