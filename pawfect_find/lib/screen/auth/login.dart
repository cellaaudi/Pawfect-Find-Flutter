import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:pawfect_find/class/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // method ke database user
  Future<bool> afterLogin(String? uid, String? name, String? email) async {
    final response = await http.post(
        Uri.parse("http://localhost/ta/Pawfect-Find-PHP/login.php"),
        body: {'uid': uid, 'name': name, 'email': email});

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);

      if (result['result'] == "Success") {
        UserDart user = UserDart.fromJson(result['data']);

        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('id_user', user.id);
        prefs.setInt('is_admin', user.isAdmin);

        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  // method login
  login() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleAcc = await googleSignIn.signIn();

      if (googleAcc != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleAcc.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        UserCredential userCred =
            await firebaseAuth.signInWithCredential(credential);

        if (userCred.user != null) {
          bool loginSuccess = await afterLogin(userCred.user?.uid, userCred.user?.displayName, userCred.user?.email);

          if (!loginSuccess) {
            await GoogleSignIn().signOut();
            FirebaseAuth.instance.signOut();
          }
        } else {
          throw Exception("Gagal terhubung dengan Firebase.");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal login: $e."),
        duration: Duration(seconds: 3),
      ));

      throw Exception('Gagal login: $e');
    }
  }

  Widget buildBody() => Center(
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 1.3 / 5,
                child: Center(
                  child: Image.asset("assets/logos/logo-white.png"),
                ),
              ),
              SizedBox(height: 32.0),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 3 / 5,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0))),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Selamat datang di",
                      style: GoogleFonts.nunito(fontSize: 16.0),
                    ),
                    Text(
                      "Pawfect Find",
                      style: GoogleFonts.nunito(
                          fontSize: 32.0, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 32.0),
                    Text(
                      "Masuk dengan Google untuk menikmati fitur yang tersedia",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(fontSize: 16.0),
                    ),
                    const SizedBox(
                      height: 32.0,
                    ),
                    OutlinedButton.icon(
                        onPressed: login,
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            padding: const EdgeInsets.all(20.0)),
                        icon: Image.asset(
                          'assets/icons/google.png',
                          height: 24.0,
                          width: 24.0,
                        ),
                        label: Text(
                          'Lanjutkan dengan Google',
                          style: GoogleFonts.nunito(fontSize: 16.0),
                        )),
                  ],
                ),
              )
            ],
          )));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: buildBody(),
    );
  }
}
