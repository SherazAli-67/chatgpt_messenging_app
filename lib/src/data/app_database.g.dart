// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AppDao? _appDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Authentication` (`id` TEXT NOT NULL, `pin` TEXT NOT NULL, `password` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Messages` (`id` TEXT NOT NULL, `userID` TEXT NOT NULL, `message` TEXT NOT NULL, `dateTime` TEXT NOT NULL, `isVoiceMessage` INTEGER NOT NULL, `path` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AppDao get appDao {
    return _appDaoInstance ??= _$AppDao(database, changeListener);
  }
}

class _$AppDao extends AppDao {
  _$AppDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _authenticationInsertionAdapter = InsertionAdapter(
            database,
            'Authentication',
            (Authentication item) => <String, Object?>{
                  'id': item.id,
                  'pin': item.pin,
                  'password': item.password
                }),
        _messagesInsertionAdapter = InsertionAdapter(
            database,
            'Messages',
            (Messages item) => <String, Object?>{
                  'id': item.id,
                  'userID': item.userID,
                  'message': item.message,
                  'dateTime': item.dateTime,
                  'isVoiceMessage': item.isVoiceMessage ? 1 : 0,
                  'path': item.path
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Authentication> _authenticationInsertionAdapter;

  final InsertionAdapter<Messages> _messagesInsertionAdapter;

  @override
  Future<Authentication?> findAuthById(int id) async {
    return _queryAdapter.query('SELECT * FROM Authentication WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Authentication(
            id: row['id'] as String,
            pin: row['pin'] as String,
            password: row['password'] as String),
        arguments: [id]);
  }

  @override
  Future<List<Messages>> getAllChatMessages() async {
    return _queryAdapter.queryList('SELECT * FROM Messages',
        mapper: (Map<String, Object?> row) => Messages(
            id: row['id'] as String,
            message: row['message'] as String,
            userID: row['userID'] as String,
            dateTime: row['dateTime'] as String,
            isVoiceMessage: (row['isVoiceMessage'] as int) != 0,
            path: row['path'] as String));
  }

  @override
  Future<void> insertUser(Authentication auth) async {
    await _authenticationInsertionAdapter.insert(
        auth, OnConflictStrategy.abort);
  }

  @override
  Future<void> sendMessage(Messages message) async {
    await _messagesInsertionAdapter.insert(message, OnConflictStrategy.abort);
  }
}
