import 'package:flutter/material.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';


PreferredSize CustomAppBar(fontsize, size) => PreferredSize(
    preferredSize: Size.fromHeight(100),
    child: Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: Color(0xff50a18e)),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, top: 20, bottom: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//    mainAxisSize: MainAxisSize.min,
          children: [
            BorderedText(
              strokeColor: Colors.black87,
              strokeWidth: 5,
              child: Text(
                "Template-Profile",
                style: GoogleFonts.lobster(
                    color: Colors.white,
                    fontSize: fontsize,
                    fontWeight: FontWeight.bold),
              ),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(
                    color: Colors.pinkAccent,
                    width: 0.8,
                  )),
              onPressed: () async {
                await launchUrlString("https://github.com/New-dev0/TgProfile");
              },
              icon: Icon(
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
                  colors: [Colors.red, Colors.pinkAccent],
                ),
              ),
            )
          ],
        ),
      ),
    ));
