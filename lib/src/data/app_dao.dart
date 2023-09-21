// dao/person_dao.dart

import 'package:floor/floor.dart';
import 'package:messenger_type_app/src/data/authentication.dart';
import 'package:messenger_type_app/src/data/messages.dart';

@dao
abstract class AppDao {
  @Query('SELECT * FROM Authentication WHERE id = :id')
  Future<Authentication?> findAuthById(int id);

  @insert
  Future<void> insertUser(Authentication auth);

  @insert
  Future<void> sendMessage(Messages message);

  @Query('SELECT * FROM Messages')
  Future<List<Messages>> getAllChatMessages();

}