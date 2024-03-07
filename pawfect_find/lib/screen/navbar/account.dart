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
      isAdmin = prefs.getInt('is_admin') ?? 0;
    });
  }

  // method untuk build body
  Widget buildBody() {
    User? user = auth.currentUser;

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Card(
                      elevation: 8.0,
                      shadowColor: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 50.0,
                          child: ClipOval(
                            child: Image.network(user?.photoURL ?? ""),
                          ),
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
                      ))),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.clear();

                        await GoogleSignIn().signOut();
                        FirebaseAuth.instance.signOut();
                      },
                      child: Text(
                        'Keluar',
                        style: GoogleFonts.nunito(
                            fontSize: 16.0, color: Colors.red),
                      )))
            ],
          )
        ],
      ),
    );
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
      ),
      body: buildBody(),
    );
  }
}
