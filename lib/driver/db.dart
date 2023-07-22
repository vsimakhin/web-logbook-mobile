import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:web_logbook_mobile/driver/db_structure.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  /// Opens the sqlite3 DB, runs the sql queries to create
  /// a DB structure on first run and might some upgrade sql
  /// queries in future
  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'logbook.db');

    final database = await openDatabase(
      path,
      version: 3,
      onCreate: (Database db, int version) async {
        await db.execute(tableLogbook);
        await db.execute(viewLogbook);
        await db.execute(deletedItems);
        await db.execute(airportTable);
        await db.execute(attachmentTable);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        switch (oldVersion) {
          case 1:
            await db.execute(airportTable);
          case 2:
            await db.execute(attachmentTable);
        }
      },
      onOpen: (db) async {},
    );

    return database;
  }
}
