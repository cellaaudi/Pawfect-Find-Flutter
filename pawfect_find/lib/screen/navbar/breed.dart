import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/breed.dart';

class BreedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BreedPage();
}

class _BreedPage extends State<BreedPage> {
  // variable buat kata yang diketik user di search box
  String _searchText = '';

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
  Widget cardBreed(breedData) => ListView.builder(
      itemCount: breedData.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return Padding(
            padding: EdgeInsets.symmetric(vertical: 6.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'detail',
                    arguments: {'breed_id': breedData[index].id as int});
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                      breedData[index].breed,
                      style: GoogleFonts.nunito(fontSize: 18.0),
                    ),
                  )
                ],
              ),
            ));
      });

  // method untuk body scaffold
  Widget displayBody() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FutureBuilder<List<Breed>>(
          future: fetchBreeds(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                return cardBreed(snapshot.data!);
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
          }));

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
                elevation: MaterialStateProperty.all(0.0),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0))),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                  fetchBreeds();
                },
              ))),
      body: displayBody(),
    );
  }
}
