import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/ui/auth/login_page.dart';
import 'package:multivendor_flutter_app/ui/public/splash_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      // initialRoute: "/",
      routes: {
        // "/": (context) => HomePage(),
        "/login": (context) => LoginPage(),
        "/logout": (context) => LoginPage(),
      },
      home: SplashPage(),
    );
  }
}
