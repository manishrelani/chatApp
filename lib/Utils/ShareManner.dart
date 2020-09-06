import 'package:shared_preferences/shared_preferences.dart';

class ShareMananer {
  static void setNumber(String number) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('number', number);
  }

  static Future<String> getNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("number")??"";
  }
}
