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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 300.0,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/card_1.jpg'),
                              fit: BoxFit.cover)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            breed.breed.toString(),
                            style: GoogleFonts.nunito(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    )
                  ],
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
        title: const Text('Detail'),
      ),
      body: Center(
        child: displayBody(args['breed_id']!),
      ),
    );
  }
}
