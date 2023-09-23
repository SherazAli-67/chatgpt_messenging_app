import 'package:floor/floor.dart';

@entity
class Messages {
  @primaryKey
  String id;
  String userID;
  String message;
  String dateTime;
  bool isVoiceMessage;
  String path;

  Messages({required this.id, required this.message, required this.userID, required this.dateTime, required this.isVoiceMessage, required this.path});

}