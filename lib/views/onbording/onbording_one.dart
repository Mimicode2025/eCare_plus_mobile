import 'package:flutter/material.dart';

class OnbordingPageOne extends StatelessWidget {
  const OnbordingPageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.asset("assets/images/onbording_one.png"),
          Text("data")
        ],
      ),
    );
  }
}
