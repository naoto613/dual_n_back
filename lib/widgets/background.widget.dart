import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final String backgroundPath;

  const Background(this.backgroundPath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundPath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
