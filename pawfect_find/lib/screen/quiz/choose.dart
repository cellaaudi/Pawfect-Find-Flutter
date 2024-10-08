import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/breed.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChoosePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChoosePage();
}

class _ChoosePage extends State<ChoosePage> {
  // variable buat kata yang diketik user di search box
  String _searchText = '';

  // variable buat observe able/disable button next
  bool btnNext = false;

  // variable buat menampung selected breeds
  // List<int> selectedBreeds = [];
  Map<int, String> selectedBreeds = {};

  // method handle perubahan isi selectedBreeds
  void changeSelected(int id, String breed) {
    setState(() {
      if (selectedBreeds.containsKey(id)) {
        selectedBreeds.remove(id);
      } else {
        if (selectedBreeds.length < 5) {
          selectedBreeds[id] = breed;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Maksimal 5 ras yang dapat dipilih",
              style: GoogleFonts.nunito(),
            ),
            duration: Duration(seconds: 3),
          ));
        }
      }

      btnNext = selectedBreeds.isNotEmpty;
    });
  }

  // search otomatis
  TextEditingController _searchController = TextEditingController();

  // method untuk confirmation message sebelum keluar quiz
  void _backMessage() {
    showDialog<void>(
        context: context,
        builder: (BuildContext ctxt) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            title: Text(
              'Konfirmasi Keluar',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Jika kamu keluar, maka jawaban kamu akan hilang.',
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
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
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
  }

  // method untuk fetch data breeds dari database
  Future<List<Breed>> fetchBreeds() async {
    try {
      final response = await http.post(
          Uri.parse('http://localhost/ta/Pawfect-Find-PHP/breed.php'),
          body: {'search': _searchText});

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == 'Success') {
          List<Breed> breeds = List<Breed>.from(
            json['data'].map((breed) => Breed.fromJson(breed)),
          );

          return breeds;
        } else {
          throw Exception("Gagal menampilkan data: ${json['message']}.");
        }
      } else {
        throw Exception(
            "Gagal menampilkan data: Status ${response.statusCode}.");
      }
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: $ex."),
        duration: Duration(seconds: 3),
      ));

      throw Exception("Terjadi kesalahan: $ex");
    }
  }

  // method untuk UI card per breed
  Widget cardBreed(Breed breed) {
    bool isSelected = selectedBreeds.containsKey(breed.id);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
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
                        return Center(child: CircularProgressIndicator(),);
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
              style: GoogleFonts.nunito(),
            ),
            trailing: TextButton.icon(
              onPressed: () {
                changeSelected(breed.id, breed.breed);
              },
              icon: Icon(
                isSelected ? Icons.delete_forever_rounded : Icons.add_rounded,
                color: isSelected ? Colors.red : Colors.blue,
              ),
              label: Text(
                isSelected ? 'Hapus' : 'Tambah',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.red : Colors.blue),
              ),
            ),
          )
        ],
      ),
    );
  }

  // method untuk UI list of breeds
  Widget displayBreeds() => FutureBuilder<List<Breed>>(
      future: fetchBreeds(),
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
            if (snapshot.data!.isNotEmpty) {
              return ListView.separated(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return cardBreed(snapshot.data![index]);
                },
                separatorBuilder: (BuildContext ctxt, int index) {
                  return Divider();
                },
              );
            } else {
              return Center(
                child: Text(
                  'Tidak ada hasil ditemukan',
                  style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                ),
              );
            }
          } else {
            return Center(
              child: Text(
                'Tidak ada hasil ditemukan',
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
              ),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      });

  // method build body
  Widget buildBody() => Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text:
                        'Pilih maksimal 5 ras anjing yang kamu inginkan. Pawfect Find akan membantu memberitahumu seberapa cocok ras tersebut dengan kamu.',
                    style: GoogleFonts.nunito(fontSize: 16))
              ]),
            ),
            SizedBox(
              height: 16.0,
            ),
            Text(
              'Daftar Ras Anjing',
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800, fontSize: 18.0),
            ),
            SizedBox(
              height: 8.0,
            ),
            Container(
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Cari ras anjing ...',
                        border: OutlineInputBorder()),
                  ))
                ],
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Expanded(child: displayBreeds()),
            SizedBox(
              height: 16.0,
            ),
            Row(
              children: [
                Expanded(
                    child: RichText(
                        text: TextSpan(
                            text:
                                "Ras anjing dipilih: ${selectedBreeds.isNotEmpty ? selectedBreeds.values.join(", ") : '-'}",
                            style: GoogleFonts.nunito(fontSize: 16.0))))
              ],
            ),
            SizedBox(
              height: 16.0,
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: btnNext
                            ? () async {
                                List<String> strSelectedBreeds = selectedBreeds
                                    .keys
                                    .map((id) => id.toString())
                                    .toList();
                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setStringList(
                                    'quiz_selectedbreeds', strSelectedBreeds);
                                Navigator.pushNamed(context, 'quiz');
                              }
                            : null,
                        child: Text(
                          'Berikutnya (${selectedBreeds.length}/5)',
                          style: GoogleFonts.nunito(),
                        )))
              ],
            )
          ],
        ),
      );

  @override
  void initState() {
    super.initState();

    btnNext = false;

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });

    fetchBreeds();
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
                  onPressed: () => _backMessage()),
              title: Text(
                'Pilih Ras Anjing',
                style: GoogleFonts.nunito(
                    fontSize: 20.0, fontWeight: FontWeight.w800),
              ),
            ),
            body: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500.0),
                child: buildBody(),
              ),
            )));
  }
}
