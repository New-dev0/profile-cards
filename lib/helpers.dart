List<String> getUrlsFromString(String text) {
  var res = <String>[];
  var rex = RegExp(r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)",);
  rex.allMatches(text).forEach((e) => res.add(e.group(0)!));
  return res;
}