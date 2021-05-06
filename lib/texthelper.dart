import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class TextPadrao extends StatelessWidget {

  String text;
  double fontSize;

  TextPadrao(String t, double fs) {
    this.text = t;
    this.fontSize = fs;
  }

  @override
  Widget build(BuildContext context) {
    return  Text(
        '$text',
        style: GoogleFonts.aBeeZee(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: this.fontSize,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.left
    );
  }
}