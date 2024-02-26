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
  List<int> selectedBreeds = [];

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
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
    final response = await http.post(
        Uri.parse('http://localhost/ta/Pawfect-Find-PHP/breed.php'),
        body: {'search': _searchText});

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);

      List<Breed> breeds = List<Breed>.from(
        json['data'].map((breed) => Breed.fromJson(breed)),
      );

      return breeds;
    } else {
      throw Exception("Gagal membaca API");
    }
  }

  // method untuk UI card per breed
  Widget cardBreed(Breed breed) {
    bool isSelected = selectedBreeds.contains(breed.id);

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
                child: Image.asset(
                  'assets/images/card_1.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              breed.breed,
              style: GoogleFonts.nunito(),
            ),
            trailing: TextButton.icon(
              onPressed: () {
                setState(() {
                  if (isSelected) {
                    selectedBreeds.remove(breed.id);
                  } else {
                    if (selectedBreeds.length < 5) {
                      selectedBreeds.add(breed.id);
                    }
                  }
                  btnNext = selectedBreeds.isNotEmpty;
                });
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
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
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
            return const Center(
              child: Text('Tidak ada hasil ditemukan'),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      });

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
                  fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text:
                            'Pilih maksimal 5 ras anjing yang kamu inginkan. Pawfect Find akan membantu memberitahumu seberapa cocok ras tersebut dengan kamu.',
                        style: GoogleFonts.nunito())
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
                        child: ElevatedButton(
                            onPressed: btnNext
                                ? () async {
                                    List<String> strSelectedBreeds =
                                        selectedBreeds
                                            .map((i) => i.toString())
                                            .toList();
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setStringList('quiz_selectedbreeds',
                                        strSelectedBreeds);
                                    Navigator.pushNamed(
                                        context, 'quiz_choices');
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
          ),
        ));
  }
}
