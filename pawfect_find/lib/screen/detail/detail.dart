import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/breed.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  // Shared Preferences
  int idBreed = 0;

  // method shared preferences id breed
  void getBreedID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idBreed = prefs.getInt('id_breed') ?? 0;
    });
  }

  // method untuk ambil data breed dari database
  Future<Breed> fetchBreed() async {
    try {
      final response = await http.post(
          Uri.parse("http://localhost/ta/Pawfect-Find-PHP/detail.php"),
          body: {'breed_id': idBreed.toString()});

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        Breed result = Breed.fromJson(json['data']);

        return result;
      } else {
        throw Exception("Gagal menampilkan detail ras anjing.");
      }
    } catch (ex) {
      throw Exception("Terjadi kesalahan: $ex");
    }
  }

  // method untuk foto anjing
  Widget imgDog(String path, String age, String name) => Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8.0,
      shadowColor: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        "http://localhost/ta/Pawfect-Find-PHP/$path"),
                    fit: BoxFit.cover)),
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
                  "$name $age",
                  style:
                      GoogleFonts.nunito(fontSize: 12.0, color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ));

  // method text
  Widget textDog(String val, String title) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(fontSize: 12.0),
          ),
          Text(
            val,
            style:
                GoogleFonts.nunito(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12.0),
        ],
      );

  // method double
  Widget dblDog(double min, double max, String title, String unit) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(fontSize: 12.0),
          ),
          Text(
            '${min.toString()} - ${max.toString()} $unit',
            style:
                GoogleFonts.nunito(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12.0),
        ],
      );

  // method untuk build body
  Widget displayBody() => SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: FutureBuilder<Breed>(
          future: fetchBreed(),
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
                Breed breed = snapshot.data!;

                return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 1),
                        shrinkWrap: true,
                        children: [
                          imgDog(breed.imgPuppy, "muda", breed.breed),
                          imgDog(breed.imgAdult, "dewasa", breed.breed)
                        ],
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Text(
                        breed.breed.toString(),
                        style: GoogleFonts.nunito(
                            fontSize: 24.0, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16.0),
                      textDog(breed.group, "Kelompok"),
                      dblDog(breed.heightMin, breed.heightMax, "Tinggi", "cm"),
                      dblDog(breed.weightMin, breed.weightMax, "berat", "kg"),
                      dblDog(breed.lifeMin, breed.lifeMax, "Kemungkinan Umur",
                          "tahun"),
                      textDog(breed.origin, "Negara Asal"),
                      textDog(breed.colour, "Warna"),
                      textDog(breed.attention, "Perhatian Khusus"),
                      Text(
                        'Kriteria',
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      if (breed.criterias!.isNotEmpty)
                        for (var c in breed.criterias!)
                          Text(
                            " - ${c['criteria']}",
                            style: GoogleFonts.nunito(
                                fontSize: 16.0, fontWeight: FontWeight.w600),
                          )
                      else
                        Center(
                          child: Text(
                            "Belum ada kriteria.",
                            style: GoogleFonts.nunito(
                                fontSize: 16.0, color: Colors.grey),
                          ),
                        )
                    ]);
              } else {
                return Center(
                  child: Text(
                    'Data tidak ditemukan.',
                    style: GoogleFonts.nunito(fontSize: 16),
                  ),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }));

  @override
  void initState() {
    super.initState();

    getBreedID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.remove('id_breed');

              Navigator.pop(context);
            }),
        title: Text(
          'Informasi Ras Anjing',
          style:
              GoogleFonts.nunito(fontSize: 20.0, fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: displayBody(),
      ),
    );
  }
}
