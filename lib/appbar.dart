import 'package:flutter/material.dart';
import 'package:bordered_text/bordered_text.dart' show BorderedText;
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart' show GradientText;


// ignore: non_constant_identifier_names
PreferredSize CustomAppBar(context, fontsize, size) => PreferredSize(
    preferredSize: const Size.fromHeight(100),
    child: Container(
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(color: Color(0xff50a18e)),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, top: 20, bottom: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//    mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (Uri.base.hasQuery) {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/");
              }},
              child: BorderedText(
                strokeColor: Colors.black87,
                strokeWidth: 5,
                child: Text(
                  "Template-Generator",
                  style: GoogleFonts.lobster(
                      color: Colors.white,
                      fontSize: fontsize,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  side: const BorderSide(
                    color: Colors.pinkAccent,
                    width: 0.8,
                  )),
              onPressed: () async {
                await launchUrlString("https://github.com/New-dev0/Template-Generator");
              },
              icon: const Icon(
                Icons.star_sharp,
                color: Colors.pinkAccent,
              ),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GradientText(
                  "Star Me",
                  style: GoogleFonts.tauri(
                    fontSize: size.width < 500 ? 12 : 15,
                  ),
                  colors: const [Colors.red, Colors.pinkAccent],
                ),
              ),
            )
          ],
        ),
      ),
    ));
