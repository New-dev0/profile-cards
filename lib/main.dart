import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:sizer/sizer.dart';

String MetaAPI = "https://tgtemp.vercel.app/";

void main() {
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MyHomePage(),
        );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var controller = TextEditingController(text: "telegram");
  GlobalKey _globalKey = new GlobalKey();
  Gradient? kbgg;
  dynamic data;
  Uint8List? byt;
  var pc1 = LinearGradient(
    colors: [
      Colors.pinkAccent,
      Colors.blueAccent
    ]
  );
  String desc = "";
  String? errort;

  void getData() {
    if (controller.text == "") {
      return;
    }
    http.post(Uri.parse("${MetaAPI}?username=${controller.text}"))
        .then((value) => {
          setState(() => data = jsonDecode(value.body)),
    if (data["photo"] != null) {
      http.get(Uri.parse(data["photo"])).then((value) => {
        setState(() => byt = value.bodyBytes)})
    }});}

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    List<Widget> MChilds = [];

    if (data["_"] != null) {
      errort = "User Not Found!";
    }
    else if (errort != null && data["name"] != null) {
        errort = null;
    }


    if (byt != null) {
      var bt = MemoryImage(byt!);
      MChilds.add(Padding(
        padding: const EdgeInsets.only(left: 18.0),
        child: CircleAvatar(backgroundImage: bt, radius: 35),
      ));
    }

    if (data["name"] != null) {
      String name = utf8.decode(data["name"].runes.toList());
      List<Widget> cchld = [
        Text(
          name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ];
      if (data["description"] != null) {
        desc = utf8.decode(data["description"].runes.toList());
        cchld.add(Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(desc, maxLines: 10),
        ));
      }

      MChilds.add(Flexible(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: cchld,
              ),
          ),
        ),
      ));
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(color: Colors.greenAccent.shade200),
          child: Padding(
            padding: const EdgeInsets.only(left: 28, top: 20, bottom: 20),
            child: BorderedText(
              strokeColor: Colors.white54,
              strokeWidth: 5,
              child: Text(
                "Telegram-Profile",
                style: GoogleFonts.lobster(
                  color: Colors.pinkAccent,
                     fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      body: Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              // Colors.greenAccent,
              Colors.pinkAccent.shade100,
              Colors.blueAccent.shade100
            ]),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  children: [
                Card(
                    color: Colors.white70,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              "Enter Username:",
                              style: GoogleFonts.lacquer(
                                color: Colors.pinkAccent,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: SizedBox(
                              width: 130,
                              child: TextField(
                                decoration: InputDecoration(errorText: errort),
                                onEditingComplete: getData,
                                controller: controller,
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white70,
                      gradient: kbgg
                      ),
                      width: 450,
                    //  height: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child:  Row(
                               children: MChilds,
                            ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Card(
                    color: Colors.white70,
                    child: Padding(
                        padding: EdgeInsets.all(15),
                        child:Column(
                      children: [Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text("1:"),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => kbgg = pc1);
                            },
                            child: Container(
                              width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: pc1
                            ),
                          ),)
                        ],
                      )],
                    )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            RenderRepaintBoundary boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
                            ui.Image img = await boundary.toImage();
                            ByteData? _ = await img.toByteData(format: ui.ImageByteFormat.png);
                            Uint8List? da = _?.buffer.asUint8List();
                            AnchorElement(href: "data:image/png;base64,${base64Encode(da!)}")
                            ..download = "Profile.png"
                              ..click();

;                        },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.indigo.shade500

                          ),
                          icon: const Icon(Icons.arrow_right),
                          label: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              "Export",
                              style: TextStyle(fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70),
                            ),
                          )),
                    ],
                  ),
                )
              ]),
            ),
          )),
      bottomNavigationBar: PreferredSize(
        preferredSize: const Size.fromHeight(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () async {
              await launchUrlString("https://github.com/New-dev0/TgProfile");
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_sharp,
                  color: Colors.purple,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: Text(
                    "Star me on GitHub",
                    style: GoogleFonts.acme(fontSize: 18),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
