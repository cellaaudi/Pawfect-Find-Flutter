import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  // Shared Preferences
  int? idUser;

  // method shared preferences id user
  void getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idUser = prefs.getInt('id_user');
    });
  }

  // method fetch histories
  Future<List<History>> fetchHistory() async {
    try {
      final response = await http.post(
          Uri.parse("http://localhost/ta/Pawfect-Find-PHP/history.php"),
          body: {'user_id': idUser.toString()});

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == "Success") {
          List<History> fetchedHist = List<History>.from(
              json['data'].map((hist) => History.fromJson(hist)));

          return fetchedHist;
        } else if (json['result'] == 'Empty') {
          return [];
        } else {
          throw Exception("Gagal menampilkan data: ${json['message']}.");
        }
      } else {
        throw Exception(
            "Gagal menampilkan data: Status ${response.statusCode}.");
      }
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $ex'),
        duration: Duration(seconds: 3),
      ));
      throw Exception("Terjadi kesalahan: $ex");
    }
  }

  // method untuk tile history
  Widget tileHistory(History history) => InkWell(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('id_history', history.id);

        Navigator.pushNamed(context, 'result');
      },
      child: ListTile(
          leading: FittedBox(
            fit: BoxFit.cover,
            child: Container(
                height: 128.0,
                width: 128.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    "${history.recommendations![0]['img']}",
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
            "${history.recommendations![0]['breed']}",
            style:
                GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            history.created_at,
            style: GoogleFonts.nunito(fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${history.recommendations![0]['cf'].toStringAsFixed(2)}%",
                style: GoogleFonts.nunito(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                width: 8,
              ),
              Icon(Icons.arrow_forward_ios_rounded)
            ],
          )));

  // method untuk data history
  Widget buildHistoryList() {
    if (idUser == null) {
      getUserID();

      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return FutureBuilder<List<History>>(
          future: fetchHistory(),
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
                List<History> histories = snapshot.data!;

                if (histories.isNotEmpty) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: histories.length,
                        itemBuilder: (context, index) {
                          History history = histories[index];

                          return tileHistory(history);
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Text(
                      'Belum ada riwayat rekomendasi.',
                      style:
                          GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
              } else {
                return Center(
                  child: Text(
                    'Belum ada riwayat rekomendasi.',
                    style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
            } else {
              return Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ));
            }
          });
    }
  }

  @override
  void initState() {
    super.initState();

    getUserID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Riwayat Rekomendasi",
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: buildHistoryList(),
    );
  }
}
