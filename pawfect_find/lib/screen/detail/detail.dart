import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/breed.dart';

class DetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  // method untuk ambil data breed dari database
  Future<Breed> fetchBreed(int breed_id) async {
    final response = await http.post(
        Uri.parse("http://localhost/ta/Pawfect-Find-PHP/detail.php"),
        body: {'breed_id': breed_id.toString()});

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      Breed result = Breed.fromJson(json['data']);
      return result;
    } else {
      throw Exception("Failed to read API");
    }
  }

  // method untuk foto anjing
  Widget imgDog(String path) => Container(
        height: 200.0,
        width: 200.0,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover)),
      );

  // method untuk build body
  Widget displayBody(int breed_id) => SingleChildScrollView(
      child: FutureBuilder<Breed>(
          future: fetchBreed(breed_id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                Breed breed = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          imgDog('assets/${breed.imgPuppy}'),
                          // imgDog('assets/${breed.imgAdult}')
                        ],
                      ),
                      Text(
                        breed.breed.toString(),
                        style: GoogleFonts.nunito(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Kelompok',
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      Text(
                        breed.group,
                        style: GoogleFonts.nunito(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Tinggi',
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      Text(
                        '${breed.heightMin.toString()} - ${breed.heightMax.toString()} cm',
                        style: GoogleFonts.nunito(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Berat',
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      Text(
                        '${breed.weightMin.toString()} - ${breed.weightMax.toString()} kg',
                        style: GoogleFonts.nunito(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Rentang Kemungkinan Umur',
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      Text(
                        '${breed.lifeMin.toString()} - ${breed.lifeMax.toString()} tahun',
                        style: GoogleFonts.nunito(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Negara Asal',
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      Text(
                        breed.origin,
                        style: GoogleFonts.nunito(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Warna',
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      Text(
                        breed.colour,
                        style: GoogleFonts.nunito(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Perhatian Khusus',
                        style: GoogleFonts.nunito(fontSize: 12.0),
                      ),
                      Text(
                        breed.attention,
                        style: GoogleFonts.nunito(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
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
          }));

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, int>;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          'Informasi Ras Anjing',
          style:
              GoogleFonts.nunito(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: displayBody(args['breed_id']!),
      ),
    );
  }
}
