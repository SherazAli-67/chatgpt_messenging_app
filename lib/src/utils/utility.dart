import 'package:intl/intl.dart';
import 'package:messenger_type_app/src/constant/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utility{
  static Future<void> saveLoginInfo(bool value)async{
    SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
    sharedPreferences.setBool(loginKey, value);
  }

  static Future<bool?> getLoginInfo()async{
    SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
    return sharedPreferences.getBool(loginKey);
  }

  static Future<void> saveUserInfo(String key, String value)async{
    SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
    sharedPreferences.setString(key, value);
  }

  static Future<String?> getUserInfo(String key)async{
    SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
    return sharedPreferences.getString(key);
  }

  static String getFormattedTime(){
    DateFormat dateFormat = DateFormat('h:mm a');
    DateTime dateTime = DateTime.now();
    return dateFormat.format(dateTime);
  }
}