import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountPage();
}

class _AccountPage extends State<AccountPage> {
  // Firebase
  late FirebaseAuth auth;

  // Shared Preferences
  int? isAdmin;

  // method shared preferences role
  void getRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = prefs.getInt('is_admin');
    });
  }

  // method logout msg
  Future<void> _logoutMsg(BuildContext context) async => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text(
            'Konfirmasi Keluar',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apakah kamu yakin ingin keluar?',
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
                  final prefs = await SharedPreferences.getInstance();
                  prefs.clear();

                  await GoogleSignIn().signOut();
                  FirebaseAuth.instance.signOut();

                  Navigator.pop(context);
                },
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

  // method button admin
  Widget btnAdmin(String title, String route) => InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.nunito(fontSize: 16),
            )
          ],
        ),
      ));

  // method untuk build body
  Widget buildBody() {
    User? user = auth.currentUser;

    if (isAdmin == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      return SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: ListTile(
                  leading: FittedBox(
                    fit: BoxFit.cover,
                    child: Container(
                        height: 128.0,
                        width: 128.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            user?.photoURL ?? "",
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
                    user?.displayName ?? "Nama",
                    style: GoogleFonts.nunito(
                        fontSize: 20.0, fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    user?.email ?? "email@gmail.com",
                    style: GoogleFonts.nunito(fontSize: 16.0),
                  ),
                  trailing: Text(
                    isAdmin == 1 ? "Admin" : "User",
                    style: GoogleFonts.nunito(fontSize: 12.0),
                  ),
                )),
              ],
            ),
            SizedBox(
              height: 24,
            ),
            Visibility(
                visible: isAdmin == 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Card(
                            elevation: 8,
                            color: Colors.white,
                            shadowColor: Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Pengaturan Data",
                                        style: GoogleFonts.nunito(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      )
                                    ],
                                  ),
                                  Divider(),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  btnAdmin("Ras Anjing", "breed_index"),
                                  btnAdmin("Kriteria", "criteria_index"),
                                  btnAdmin("Aturan", "rule_index"),
                                  btnAdmin("Kuis", "quiz_index"),
                                  // btnAdmin("Pilihan Jawaban"),
                                ],
                              ),
                            )))
                  ],
                )),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    auth = FirebaseAuth.instance;
    getRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Akun",
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () async => await _logoutMsg(context),
            icon: Icon(Icons.logout_rounded),
            tooltip: "Keluar",
            style: IconButton.styleFrom(foregroundColor: Colors.red),
          )
        ],
      ),
      body: buildBody(),
    );
  }
}
