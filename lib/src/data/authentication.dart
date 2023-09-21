import 'package:floor/floor.dart';

@entity
class Authentication{
  @primaryKey
  String id;
  String pin;
  String password;

  Authentication({required this.id, required this.pin, required this.password});
}