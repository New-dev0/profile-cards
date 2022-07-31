import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:image/image.dart' as ip;

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
  Uint8List? pfp;
  int cindex = 0;
  dynamic kbgg;
  dynamic data;
  Map<int, Map<String, dynamic>> CacheData = {0: {}, 1: {}};
  List<dynamic> Themes = [
    <Color>[Colors.pinkAccent, Colors.blueAccent],
    [Color(0xffff0f7b), Color(0xfff89b29)],
    [Color(0xffe81cff), Color(0xff45caff)],
    Colors.lime,
    Colors.indigoAccent,
  ];
  String desc = "";
  String? errort;
  bool? _expand = false;
  dynamic dropvalue;
  late List<dynamic> s_icons;
  Icon tgicon = Icon(
    Icons.telegram,
    size: 40,
    color: Colors.blue.shade700,
  );

  void _getPhoto() {
    if (data["photo"] != null) {
      http.get(Uri.parse(data["photo"])).then((value) => pfp = value.bodyBytes);
    }
  }

  void getData() {
    String text = controller.text;
    if (text == "") {
      return;
    }
    if (CacheData[cindex]!.containsKey(text)) {
      setState(() => data = CacheData[cindex]![text]);
      _getPhoto();
      return;
    }
    ;

    if (cindex == 0) {
      http.post(Uri.parse("${MetaAPI}?username=${text}")).then((value) => {
            setState(() => data = jsonDecode(value.body)),
            CacheData[0]![text] = data,
            _getPhoto()
          });
    } else {
      http
          .get(Uri.parse("https://api.github.com/users/${text}"))
          .then((value) => {
                setState(() => data = jsonDecode(value.body)),
                if (data.containsKey("message")) {data["_"] = data["message"]},
                data["photo"] = data["avatar_url"],
                data["description"] = data["bio"],
                if (data["name"] == null) {data["name"] = data["login"]},
                CacheData[cindex]![text] = data,
              });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    s_icons = [
      tgicon,
      ImageIcon(
          NetworkImage("https://cdn.onlinewebfonts.com/svg/img_415633.png"))
    ];
    dropvalue = tgicon;
  }

  List<Widget> themeBox() {
    return Themes.map((e) {
      Gradient? gr;
      Color? col;
      if (e is List<Color>) {
        gr = LinearGradient(colors: e);
      } else {
        col = e;
      }
      return GestureDetector(
        onTap: () {
          setState(() => kbgg = gr ?? col);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black87, width: 0.2),
                borderRadius: BorderRadius.circular(5),
                gradient: gr,
                color: col),
          ),
        ),
      );
    }).toList();
  }

  String tryDecode(String data) {
    try {
      return utf8.decode(data.runes.toList());
    } catch (e) {
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Center(
          child:
              LoadingAnimationWidget.beat(color: Colors.tealAccent, size: 100));
    }
    List<Widget> MChilds = [];
    if (data["_"] != null) {
      errort = "User Not Found!";
    } else if (errort != null && data["name"] != null) {
      errort = null;
    }
    if (_expand == false) {
      if (data["photo"] != null) {
        MChilds.add(Padding(
          padding: const EdgeInsets.only(left: 18.0, top: 25, bottom: 25),
          child: CircleAvatar(
              backgroundImage: NetworkImage(data["photo"]), radius: 35),
        ));
      }

      if (data["name"] != null) {
        String name = tryDecode(data["name"]);
        List<Widget> cchld = [
          Text(
            name,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            maxLines: 1,
          ),
        ];
        if (data["description"] != null) {
          desc = tryDecode(data["description"]);
          cchld.add(Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(desc, maxLines: 10),
          ));
        }

        MChilds.add(Flexible(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 450,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: cchld,
              ),
            ),
          ),
        ));
      }
    } else {
      if (data["photo"] != null) {
        MChilds.addAll([
          Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        data["photo"],
                        width: MediaQuery.of(context).size.height / 4,
                      )),
                )
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
        ]);
        if (data["name"] != null) {
          MChilds.add(Text(
            tryDecode(data["name"]),
            style: TextStyle(fontSize: 25),
          ));
        }
        if (data["description"] != null) {
          MChilds.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
                width: 350,
                child: Text(
                  tryDecode(data["description"]),
                  style: TextStyle(color: Colors.black87),
                )),
          ));
        }
      }
    }
    List<Widget> PrimCol = [
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Text("1:"),
      ),
    ];
    PrimCol.addAll(themeBox());
    PrimCol.add(Padding(
      padding: EdgeInsets.only(left: 12),
      child: TextButton(
        style: TextButton.styleFrom(backgroundColor: Colors.white70),
        child: Text("More"),
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: kbgg is Color ? kbgg : Colors.white70,
                      onColorChanged: (Color value) {
                        setState(() => kbgg = value);
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("SELECT"))
                  ],
                );
              });
        },
      ),
    ));
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(color: Color(0xff50a18e)),
              child: Padding(
                padding: const EdgeInsets.only(left: 28, top: 20, bottom: 20),
                child: BorderedText(
                  strokeColor: Colors.black87,
                  strokeWidth: 5,
                  child: Text(
                    "Template-Profile",
                    style: GoogleFonts.lobster(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ))),
      body: Container(
          decoration: BoxDecoration(color: Color(0xffd0e0e3)),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0),
                        child: DropdownButton<dynamic>(
                          elevation: 0,
                          value: dropvalue,
                          dropdownColor: Colors.white70,
                          iconSize: 0,
                          items: s_icons
                              .map((e) =>
                                  DropdownMenuItem<dynamic>(value: e, child: e))
                              .toList(),
                          onChanged: (_) {
                            setState(() =>
                                {dropvalue = _, cindex = s_icons.indexOf(_)});
                          },
                        ),
                      ),
                      SizedBox(
                        width: 270,
                        child: TextField(
                          autofocus: true,
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              errorText: errort, hintText: "Enter Username"),
                          onEditingComplete: getData,
                          controller: controller,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kbgg is Color ? kbgg : Colors.white70,
                        gradient: kbgg is Gradient ? kbgg : null,
                      ),
                      width: 550,
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Flexible(
                              child: !_expand!
                                  ? Row(
                                      children: MChilds,
                                    )
                                  : Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Column(children: MChilds)),
                            )),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: PrimCol,
                          ),
                          Padding(padding: EdgeInsets.only(top: 15)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Expand Mode:"),
                              Checkbox(
                                  value: _expand,
                                  onChanged: (bool? value) {
                                    setState(() => _expand = value);
                                  })
                            ],
                          ),
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            RenderRepaintBoundary boundary =
                                _globalKey.currentContext?.findRenderObject()
                                    as RenderRepaintBoundary;
                            ui.Image img = await boundary.toImage();
                            ByteData? _ = await img.toByteData(
                                format: ui.ImageByteFormat.png);
                            Uint8List? da = _?.buffer.asUint8List();
                            if (pfp != null) {
                              ip.Image? dimg = ip.decodePng(da!);
                              ip.Image? pfpn = ip.decodeImage(pfp!);
                              ip.Image cropp = ip.copyCropCircle(pfpn!);
                              ip.Image res =
                                  ip.copyResize(cropp, width: 71, height: 71);
                              ip.Image newp =
                                  ip.copyInto(dimg!, res, dstX: 51, dstY: 58);
                              da = ip.encodePng(newp) as Uint8List;
                            }
                            // await showDialog(
                            //     context: context,
                            //     builder: (_) {
                            //       return AlertDialog(
                            //         content: Image.memory(da!),
                            //       );
                            //     });
                            // return;
                            AnchorElement(
                                href:
                                    "data:image/png;base64,${base64Encode(da!)}")
                              ..download = "Profile.png"
                              ..click();
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.indigo.shade500),
                          icon: const Icon(Icons.arrow_right),
                          label: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              "Export",
                              style: TextStyle(
                                  fontSize: 18,
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
          padding: const EdgeInsets.symmetric(vertical: 13.0),
          child: InkWell(
            onTap: () async {
              await launchUrlString("https://github.com/New-dev0/TgProfile");
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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
