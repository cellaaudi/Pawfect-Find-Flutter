import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/breed.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Widget cardBreed(Breed breed) => InkWell(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('id_breed', breed.id);
        
        Navigator.pushNamed(context, 'detail');
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8.0,
        shadowColor: Colors.grey.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Ink.image(
              image: NetworkImage("http://localhost/ta/Pawfect-Find-PHP/${breed.imgAdult}"),
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.transparent,
                  ])),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    breed.breed,
                    style: GoogleFonts.nunito(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )
                ],
              ),
            )
          ],
        ),
      ));

  // method untuk body scaffold
  Widget displayBody() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<List<Breed>>(
          future: fetchBreeds(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                // return cardBreed(snapshot.data!);
                return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return cardBreed(snapshot.data![index]);
                    });
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
