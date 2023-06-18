import 'dart:math';

String systemFriendlyFileName(String name) {
  return name.replaceAll(RegExp(r'[ /\\<>:"|?*.]'), '');
}

String limitDisplayStringLength(String data, int maxLength) {
  String output = data.substring(0, min(data.length, maxLength));
  if (data.length > maxLength) {
    output += "...";
  }
  return output;
}

String encodeForUrlParam(String data) {
  data = data.replaceAll(RegExp(r' '), "%20");
  data = data.replaceAll(RegExp(r'/'), "%2F");
  data = data.replaceAll(RegExp(r'\?'), "%3F");
  data = data.replaceAll(RegExp(r'\r?\n'), "%0A");
  return data.replaceAll(RegExp(r'#'), "%23");
}
