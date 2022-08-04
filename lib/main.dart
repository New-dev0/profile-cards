import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'helpers.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'appbar.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// ignore: non_constant_identifier_names
String MetaAPI = "https://tgtemp.vercel.app/";

void main() {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
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
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) {
        return const MyHomePage();
      }),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var controller = TextEditingController(
      text: Uri.base.queryParameters["query"] ?? "telegram");
  final GlobalKey _globalKey = GlobalKey();
  int cindex = Uri.base.queryParameters["index"] != null ? int.parse(Uri.base.queryParameters["index"]!) : 0;
  double imgradius = 100;
  dynamic kbgg;
  dynamic data;
  bool _autofocus = true;
  Map<int, Map<String, dynamic>> CacheData = {};
  List<dynamic> Themes = [
    const [Color(0xff020344), Color(0xff28b8d5)],
    [const Color(0xffff0f7b), const Color(0xfff89b29)],
    [const Color(0xffe81cff), const Color(0xff45caff)],
    const [Color(0xffcf414b), Color(0xff852170)],
    [Colors.teal, Colors.green],
    Colors.indigoAccent,
  ];
  double cardopac = 1;
  String desc = "";
  bool highlight_url = false;
  bool _show_highl = false;
  bool _show_prem = false;
  String? errort;
  bool _dark = Uri.base.queryParameters["dark"] == "true";
  bool? _expand = Uri.base.queryParameters["expand"] == "true";
  dynamic dropvalue;
  late List<dynamic> s_icons;
  Icon tgicon = Icon(
    Icons.telegram,
    size: 40,
    color: Colors.blue.shade700,
  );

  void download_image({url = false}) async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    late ui.Image img;
    try {
      img = await boundary.toImage(pixelRatio: 2);
    } catch (e) {
      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text(
                "$e\nTake Screenshot from your device and crop it to get template."),
          );
        },
      );
      return;
    }
    ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? buffer = byteData?.buffer.asUint8List();
    if (url) {
      var request =
          http.MultipartRequest('POST', Uri.parse('https://imgwhale.xyz/new'));
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        buffer!,
      ));

      var response = await request.send();
      var json = jsonDecode(await response.stream.bytesToString());
      String imgurl = "https://imgwhale.xyz/${json['fileId']}";
      await showDialog(
        context: context,
        builder: (context) {
          String text = "COPY";
          return StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return SimpleDialog(
                  title: const Text(
                    'Success',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Image Uploaded successfully to ImgWhale!',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 28.0),
                          child: Row(
                            children: [
                              const Spacer(),
                              TextButton(
                                  onPressed: () async {
                                    Clipboard.setData(
                                        ClipboardData(text: imgurl));
                                    setState(() {
                                      text = "COPIED!";
                                    });
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    Navigator.pop(context);
                                  },
                                  child: Text(text,
                                      style: const TextStyle(fontSize: 13))),
                              TextButton(
                                child: const Text(
                                  'OPEN',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                onPressed: () async {
                                  await launchUrlString(imgurl);
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ]);
            },
          );
        },
      );
      return;
    }
    // if (pfp != null &&
    // !window.navigator.userAgent
    //   .toLowerCase()
    // .contains(RegExp("iphone|ipad"))) {
    // ip.Image? dimg = ip.decodePng(da!);
    // ip.Image? pfpn = ip.decodeImage(pfp!);
    // ip.Image cropp = ip.copyCropCircle(pfpn!);
    // int rad = !_expand! ? 71 : 218;
    // ip.Image res =
    //   ip.copyResize(cropp, width: rad, height: rad);
    // ip.Image newp = ip.copyInto(dimg!, res,
    //    dstX: _expand! ? 166 : 51,
    //    dstY: _expand! ? 56 : 58);
    //da = ip.encodePng(newp) as Uint8List;
    //  }

    if (!kReleaseMode) {
      await showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              backgroundColor: Colors.tealAccent,
              content: Image.memory(buffer!),
            );
          });
      return;
    }
    AnchorElement(href: "data:image/png;base64,${base64Encode(buffer!)}")
      ..download = "${controller.text}-profile.png"
      ..click();
  }

  void getData() {
    _show_prem = false;
    String text = controller.text;
    if (text == "") {
      return;
    }
    if (CacheData[cindex] == null) {
      CacheData[cindex] = {};
    }
    if (CacheData[cindex]!.containsKey(text)) {
      setState(() => data = CacheData[cindex]![text]);
      return;
    }

    if (cindex == 1) {
      http
          .get(Uri.parse("https://api.github.com/users/$text"))
          .then((value) => {
                setState(() => data = jsonDecode(value.body)),
                if (data.containsKey("message"))
                  {data["_"] = data["message"]}
                else
                  {
                    data["photo"] = data["avatar_url"],
                    data["description"] = data["bio"],
                    if (data["name"] == null) {data["name"] = data["login"]}
                  },
                CacheData[cindex]![text] = data,
              });
    } else {
      var quer = cindex == 0 ? "username" : "twitter";
      http.post(Uri.parse("$MetaAPI?$quer=$text")).then((value) => {
            setState(() => data = jsonDecode(value.body)),
            if (cindex == 0) {data["url"] = "https://t.me/$text"},
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
      Image.network(
        'https://cdn-icons-png.flaticon.com/512/2111/2111425.png',
        width: 30,
      ),
      Image.network("https://img.icons8.com/fluency/48/000000/twitter.png",
          width: 30)
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
      return Scaffold(
        backgroundColor: Colors.teal.shade100,
        body: Center(
            child: LoadingAnimationWidget.beat(color: Colors.teal, size: 100)),
      );
    }
    var size = MediaQuery.of(context).size;
    double fontsize = size.width < 500 ? 32 : 40;
    List<Widget> MChilds = [];
    Color textcol = _dark ? Colors.white70 : Colors.black;
    Widget? desk;

    if (data["_"] != null) {
      errort = "User Not Found!";
    } else {
      if (errort != null && data["name"] != null) {
        errort = null;
      }
      if (data["description"] != null) {
        var align = _expand! ? TextAlign.center : TextAlign.start;
        String dec = tryDecode(data["description"]);
        List<String> urls = getUrlsFromString(dec);
        if (urls.isNotEmpty) {
          _show_highl = true;
        }
        desk = Text(
          dec,
          textAlign: align,
          style: TextStyle(color: textcol),
        );
        if (highlight_url) {
          if (_show_highl) {
            var dchild = <TextSpan>[];
            dec.split(" ").forEach((String element) {
              Color tcolor;
              GestureRecognizer? gr;
              if (urls.contains(element)) {
                var te =
                    element.startsWith("http") ? element : "https://" + element;
                tcolor = Colors.blueAccent.shade200;
                gr = TapGestureRecognizer()
                  ..onTap = () async {
                    await launchUrlString(te.trim());
                  };
              } else {
                tcolor = textcol;
              }
              dchild.add(TextSpan(
                  text: "$element ",
                  recognizer: gr,
                  style: TextStyle(
                    color: tcolor,
                  )));
            });
            desk = RichText(
              text: TextSpan(children: dchild),
              textAlign: align,
            );
          }
        }
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
            Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textcol),
                  maxLines: 1,
                ),
                if (_show_prem)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Image.asset(
                      "assets/premium.png",
                      width: 28,
                    ),
                  )
              ],
            ),
          ];
          if (desk != null) {
            //   desc = tryDecode(data["description"]);
            cchld.add(Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: desk,
            ));
          }

          MChilds.add(Flexible(
            child: Padding(
              padding: const EdgeInsets.all(22),
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
                      borderRadius: BorderRadius.circular(imgradius),
                      child: data["photo"] != null
                          ? Image.network(data["photo"], width: 200)
                          : QrImage(
                              data: data["url"],
                              size: 200,
                              foregroundColor: textcol,
                              semanticsLabel: controller.text,
                            )),
                )
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
        ]);
        if (data["name"] != null) {
          MChilds.add(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tryDecode(data["name"]),
                style: TextStyle(fontSize: 25, color: textcol),
              ),
              if (_show_prem)
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Image.asset("assets/premium.png", width: 28),
                )
            ],
          ));
        }
        if (desk != null) {
          MChilds.add(Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: 350,
                child: desk,
              )));
        }
      }
    }
    List<Widget> PrimCol = [
      const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Text("1:"),
      ),
    ];
    PrimCol.addAll(themeBox());
    PrimCol.add(Padding(
      padding: const EdgeInsets.only(left: 12),
      child: TextButton(
        style: TextButton.styleFrom(backgroundColor: Colors.white70),
        child: const Text("More"),
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
                        child: const Text("SELECT"))
                  ],
                );
              });
        },
      ),
    ));

    return Scaffold(
      backgroundColor: const Color(0xffd0e0e3),
      appBar: CustomAppBar(context, fontsize, size),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: DropdownButton<dynamic>(
                      elevation: 0,
                      underline: null,
                      value: dropvalue,
                      dropdownColor: Colors.white70,
                      iconSize: 0,
                      items: s_icons
                          .map((e) =>
                              DropdownMenuItem<dynamic>(value: e, child: e))
                          .toList(),
                      onChanged: (_) {
                        setState(
                            () => {dropvalue = _, cindex = s_icons.indexOf(_)});
                      },
                    ),
                  ),
                  SizedBox(
                    width: 270,
                    child: TextField(
                      autofocus: _autofocus,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          errorText: errort, hintText: "Enter Username"),
                      onEditingComplete: () {
                        getData();
                        _autofocus = false;
                      },
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
                    gradient: kbgg is Gradient
                        ? kbgg
                        : (_dark ? LinearGradient(colors: Themes[0]) : null),
                  ),
                  width: 550,
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Opacity(
                      opacity: cardopac,
                      child: Card(
                          color: _dark
                              ? Colors.black87.withOpacity(.65)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: !_expand!
                              ? Row(
                                  children: MChilds,
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(children: MChilds))),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: PrimCol,
                      ),
                      const Padding(padding: EdgeInsets.only(top: 15)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Expand Mode:"),
                          Checkbox(
                              value: _expand,
                              onChanged: (bool? value) {
                                setState(() => _expand = value);
                              }),
                          const Padding(padding: EdgeInsets.only(left: 10)),
                          if (_show_highl) const Text("Highlight Url:"),
                          if (_show_highl)
                            Checkbox(
                                value: highlight_url,
                                onChanged: (value) {
                                  setState(() {
                                    highlight_url = value as bool;
                                  });
                                }),
                          if (data["premium"] == true)
                            const Icon(
                              Icons.star,
                              color: Colors.pinkAccent,
                            ),
                          if (data["premium"] == true)
                            Checkbox(
                                value: _show_prem,
                                onChanged: (bool? _) {
                                  setState(() => _show_prem = _ as bool);
                                }),
                          const Text("Dark:"),
                          Checkbox(
                            value: _dark,
                            onChanged: (_) {
                              setState(() => _dark = _ as bool);
                            },
                          )
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Card Opacity:"),
                          Slider(
                            value: cardopac,
                            min: 0.6,
                            onChanged: (double value) {
                              setState(() {
                                cardopac = value;
                              });
                            },
                          )
                        ],
                      ),
                      if (_expand!)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Image Radius:"),
                            Slider(
                                value: imgradius,
                                min: 50,
                                max: 100,
                                onChanged: (_) {
                                  setState(() {
                                    imgradius = _;
                                  });
                                })
                          ],
                        )
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ColoredBox(
                    color: Colors.indigo,
                    child: PopupMenuButton(
                      tooltip: "",
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      offset: const Offset(90, 30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.arrow_right,
                              color: Colors.indigoAccent,
                            ),
                            Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                "Export",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                              onTap: download_image,
                              child: const Text(
                                "As PNG",
                                style: TextStyle(fontSize: 14),
                              )),
                          PopupMenuItem(
                              child: const Text(
                                "To URL",
                                style: TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                download_image(url: true);
                              })
                        ];
                      },
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
