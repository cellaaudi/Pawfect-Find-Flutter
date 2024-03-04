import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pawfect_find/screen/auth/login.dart';
import 'package:pawfect_find/screen/detail/detail.dart';
import 'package:pawfect_find/screen/navbar/breed.dart';
import 'package:pawfect_find/screen/navbar/home.dart';
import 'package:pawfect_find/screen/navbar/settings.dart';
import 'package:pawfect_find/screen/quiz/choose.dart';
import 'package:pawfect_find/screen/quiz/quiz.dart';
import 'package:pawfect_find/screen/quiz/result.dart';
import 'package:pawfect_find/screen/quiz/quiz_afchoose.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyD0diqklhO6VR6_VUNkGaaSdcCRkRDfOyk",
            appId: "1:961868821442:web:5b4e57ed0f7e7a564e1c5b",
            messagingSenderId: "961868821442",
            projectId: "pawfect-find-firebase"));
  }

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)))),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.blue,
                  width: 1.3,
                ),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)))),
          )),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctxt, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return LoginPage();
            } else {
              return MyHomePage(title: 'Pawfect Find');
            }
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      routes: {
        'login': (context) => LoginPage(),
        'breed': (context) => BreedPage(),
        'detail': (context) => DetailPage(),
        'quiz': (context) => QuizPage(),
        'choose': (context) => ChoosePage(),
        'quiz_choices': (context) => QuizChoosePage(),
        'result': (context) => ResultPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomePage(),
    BreedPage(),
    SettingsPage()
  ];

  Widget navbar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      fixedColor: Colors.blue,
      items: [
        BottomNavigationBarItem(
            label: "Beranda", icon: Icon(Icons.home_rounded)),
        BottomNavigationBarItem(
          label: "Ras Anjing",
          icon: Icon(Icons.pets_rounded),
        ),
        BottomNavigationBarItem(
            label: "Pengaturan", icon: Icon(Icons.settings_rounded)),
      ],
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500.0),
        child: _screens[_currentIndex],
      )),
      bottomNavigationBar: navbar(),
    );
  }
}
