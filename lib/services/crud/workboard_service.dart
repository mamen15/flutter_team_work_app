import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/extensions/list/filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'crud_exception.dart';

class WorkBoardService {
  Database? _db;

  List<DatabaseWorkBoard> _workboards = [];

  DatabaseUser? _user;

  static final WorkBoardService _shared = WorkBoardService._sharedInstance();
  WorkBoardService._sharedInstance() {
    _workboardStreamController =
        StreamController<List<DatabaseWorkBoard>>.broadcast(
      onListen: () {
        _workboardStreamController.sink.add(_workboards);
      },
    );
  }
  factory WorkBoardService() => _shared;

  late final StreamController<List<DatabaseWorkBoard>>
      _workboardStreamController;
  Stream<List<DatabaseWorkBoard>> get allWorkBoards =>
      _workboardStreamController.stream.filter((workboard) {
        final currentUser = _user;
        if (currentUser != null) {
          return workboard.userId == currentUser.id;
        } else {
          throw UserShoulBeSetBeforeReadingAllWorkboards();
        }
      });

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(
        email: email,
      );
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheWorkBoard() async {
    final allWorkBoards = await getAllWorkBoards();
    _workboards = allWorkBoards.toList();
    _workboardStreamController.add(_workboards);
  }

  Future<DatabaseWorkBoard> updateWorkBoard({
    required DatabaseWorkBoard workboard,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure workboards exists
    await getWorkBoard(id: workboard.id);

    // update DB
    final updatesCount = await db.update(
      workboardTable,
      {
        textColumn: text,
        isSyncedWithCloudColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [workboard.id],
    );

    if (updatesCount == 0) {
      throw CouldNoUpdateWorkBoard();
    } else {
      final updatedWorkBoard = await getWorkBoard(id: workboard.id);
      _workboards
          .removeWhere((workboard) => workboard.id == updatedWorkBoard.id);
      _workboards.add(updatedWorkBoard);
      _workboardStreamController.add(_workboards);
      return updatedWorkBoard;
    }
  }

  Future<Iterable<DatabaseWorkBoard>> getAllWorkBoards() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final workboard = await db.query(
      workboardTable,
    );
    return workboard.map((wbRow) => DatabaseWorkBoard.fromRow(wbRow));
  }

  Future<DatabaseWorkBoard> getWorkBoard({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final workboards = await db.query(
      workboardTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (workboards.isEmpty) {
      throw CouldNotFindWorkBoard();
    } else {
      final workboard = DatabaseWorkBoard.fromRow(workboards.first);
      _workboards.removeWhere((workboard) => workboard.id == id);
      _workboards.add(workboard);
      _workboardStreamController.add(_workboards);
      return workboard;
    }
  }

  Future<int> deleteAllWorkBoards() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(workboardTable);
    _workboards = [];
    _workboardStreamController.add(_workboards);
    return numberOfDeletions;
  }

  Future<void> deleteWorkBoard({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      workboardTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteWorkBoard();
    } else {
      _workboards.removeWhere((workboard) => workboard.id == id);
      _workboardStreamController.add(_workboards);
    }
  }

  Future<DatabaseWorkBoard> createWorkBoard(
      {required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in db with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';
    //create the note
    final workboardId = await db.insert(workboardTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });
    final workboard = DatabaseWorkBoard(
      id: workboardId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _workboards.add(workboard);
    _workboardStreamController.add(_workboards);
    return workboard;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) throw CouldNotDeleteUser();
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpen;
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpen;
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create the user table
      await db.execute(createUserTable);
      // create WorkBoard table
      await db.execute(createWorkBoardTable);
      await _cacheWorkBoard();
    } on MissingPlatformDirectoryException {
      throw UnableTogetDocumentDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person , ID =$id,email =$email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseWorkBoard {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseWorkBoard({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DatabaseWorkBoard.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'woarkboard , ID =$id, userId =$userId, text = $text, isSyncedWithCloud = $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseWorkBoard other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'woardboard.db';
const userTable = 'user';
const workboardTable = 'workboard';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

// create User Table
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	      "id"	INTEGER NOT NULL,
	      "email"	TEXT NOT NULL UNIQUE,
	      PRIMARY KEY("id" AUTOINCREMENT)
      );''';

// create WorkBoard Table
const createWorkBoardTable = '''CREATE TABLE IF NOT EXISTS "WorkBoard" (
      	"id"	INTEGER NOT NULL,
      	"user_id"	INTEGER NOT NULL,
      	"text"	TEXT,
      	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
      	FOREIGN KEY("user_id") REFERENCES "user"("id"),
      	PRIMARY KEY("id" AUTOINCREMENT)
      );''';
