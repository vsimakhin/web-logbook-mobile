import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'package:web_logbook_mobile/models/models.dart';
import 'package:web_logbook_mobile/driver/db_structure.dart';
import 'package:web_logbook_mobile/helpers/helpers.dart';

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
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute(tableLogbook);
        await db.execute(viewLogbook);
        await db.execute(deletedItems);
        await db.execute(airportTable);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        switch (oldVersion) {
          case 1:
            await db.execute(airportTable);
        }
      },
      onOpen: (db) async {},
    );

    return database;
  }

  /// Returns all flight records from the database and orders them by date
  Future getAllFlightRecords() async {
    final db = await database;
    return await db!.rawQuery(
      '''SELECT * FROM logbook_view ORDER BY m_date DESC''',
    );
  }

  /// Returns all removed items
  Future getDeletedItems() async {
    final db = await database;
    return await db!.rawQuery(
      '''SELECT uuid, table_name, delete_time FROM deleted_items''',
    );
  }

  /// Saves a flight record. If the flight record is new,
  /// generates a new UUID and inserts it into the database. Otherwise, updates
  /// the existing record with the latest data.
  Future saveFlightRecord(FlightRecord fr) async {
    if (fr.isNew) {
      fr.uuid = const Uuid().v4();
      fr.updateTime = getEpochTime();
      return await insertFlightRecord(fr);
    } else {
      fr.updateTime = getEpochTime();
      return await updateFlightRecord(fr);
    }
  }

  /// Creates a new record in the logbook table with the provided
  /// flight record data [fr].
  Future<dynamic> insertFlightRecord(FlightRecord fr) async {
    final db = await database;

    return await db!.rawInsert('''INSERT INTO logbook
        (uuid, date, departure_place, departure_time, arrival_place,
        arrival_time, aircraft_model, reg_name, se_time, me_time,
        mcc_time, total_time, day_landings, night_landings, night_time,
        ifr_time, pic_time, co_pilot_time, dual_time, instructor_time,
        sim_type, sim_time, pic_name, remarks, update_time)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
        ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
      fr.uuid,
      fr.date,
      fr.departurePlace,
      fr.departureTime,
      fr.arrivalPlace,
      fr.arrivalTime,
      fr.aircraftModel,
      fr.aircraftReg,
      fr.timeSE,
      fr.timeME,
      fr.timeMCC,
      fr.timeTT,
      fr.dayLandings,
      fr.nightLandings,
      fr.timeNight,
      fr.timeIFR,
      fr.timePIC,
      fr.timeCOP,
      fr.timeDual,
      fr.timeInstr,
      fr.simType,
      fr.simTime,
      fr.picName,
      fr.remarks,
      fr.updateTime,
    ]);
  }

  /// Updates the flight record in the logbook table with the provided
  /// flight record data [fr].
  Future updateFlightRecord(FlightRecord fr) async {
    final db = await database;

    return await db!.rawUpdate('''UPDATE logbook
        SET date = ?, departure_place = ?, departure_time = ?,
        arrival_place = ?, arrival_time = ?, aircraft_model = ?,
        reg_name = ?, se_time = ?, me_time = ?, mcc_time = ?,
        total_time = ?, day_landings = ?, night_landings = ?,
        night_time = ?, ifr_time = ?, pic_time = ?, co_pilot_time = ?,
        dual_time = ?, instructor_time = ?, sim_type = ?,
        sim_time = ?, pic_name = ?, remarks = ?, update_time = ?
        WHERE uuid = ?
        ''', [
      fr.date,
      fr.departurePlace,
      fr.departureTime,
      fr.arrivalPlace,
      fr.arrivalTime,
      fr.aircraftModel,
      fr.aircraftReg,
      fr.timeSE,
      fr.timeME,
      fr.timeMCC,
      fr.timeTT,
      fr.dayLandings,
      fr.nightLandings,
      fr.timeNight,
      fr.timeIFR,
      fr.timePIC,
      fr.timeCOP,
      fr.timeDual,
      fr.timeInstr,
      fr.simType,
      fr.simTime,
      fr.picName,
      fr.remarks,
      fr.updateTime,
      fr.uuid,
    ]);
  }

  /// Deletes a flight record
  Future<dynamic> deleteFlightRecord(String uuid) async {
    final db = await database;
    if (db == null) return 'cannot initialize connection to database';

    final res = await db.rawDelete(
      '''DELETE FROM logbook WHERE uuid = ?''',
      [uuid],
    );

    if (res == 0) return 'no record with uuid $uuid found';

    await db.rawInsert(
      '''INSERT INTO deleted_items (uuid, table_name, delete_time)
        VALUES(?, ?, ?)''',
      [
        uuid,
        'logbook',
        getEpochTime(),
      ],
    );

    return null;
  }
}
