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
            title: Text(breed.breed),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 80.0,
          flexibleSpace: Padding(
              padding: EdgeInsets.all(16.0),
              child: SearchBar(
                leading: Icon(Icons.search_rounded),
                hintText: 'Cari ras anjing',
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shadowColor: MaterialStateProperty.all(Colors.grey.shade50),
                elevation: MaterialStateProperty.all(8.0),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0))),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                  fetchBreeds();
                },
              ))),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text:
                        'Pilih maksimal 5 ras anjing yang kamu inginkan. Pawfect Find akan membantu memberitahumu seberapa cocok ras tersebut dengan kamu.')
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
                                List<String> strSelectedBreeds = selectedBreeds
                                    .map((i) => i.toString())
                                    .toList();
                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setStringList(
                                    'quiz_selectedbreeds', strSelectedBreeds);
                                Navigator.pushNamed(context, 'quiz_choices');
                              }
                            : null,
                        child: Text('Berikutnya (${selectedBreeds.length}/5)')))
              ],
            )
          ],
        ),
      ),
    );
  }
}
