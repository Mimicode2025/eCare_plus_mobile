import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const Home(),
      routes: <String, WidgetBuilder>{
        OnbordingPageOne.routeName: (BuildContext context) => const OnbordingPageOne(),
        AjoutComptePage.routeName: (BuildContext context) =>
            const AjoutComptePage(),
        ClavierPage.routeName: (BuildContext context) => const ClavierPage(),
        AppelPage.routeName: (BuildContext context) => const AppelPage(),
        ContactPage.routeName: (BuildContext context) => const ContactPage(),
        AdministrateurPage.routeName: (BuildContext context) =>
            const AdministrateurPage(),
      },
    );
  }
}