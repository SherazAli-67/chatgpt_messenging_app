// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:messenger_type_app/src/data/app_dao.dart';
import 'package:messenger_type_app/src/data/authentication.dart';
import 'package:messenger_type_app/src/data/messages.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Authentication, Messages])
abstract class AppDatabase extends FloorDatabase {
  AppDao get appDao;
}