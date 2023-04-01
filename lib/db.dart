import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  static const tableLogbook = '''
    CREATE TABLE IF NOT EXISTS logbook (
      uuid TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      departure_place TEXT,
      departure_time TEXT,
      arrival_place TEXT,
      arrival_time TEXT,
      aircraft_model TEXT,
      reg_name TEXT,
      se_time TEXT,
      me_time TEXT,
      mcc_time TEXT,
      total_time TEXT,
      day_landings INTEGER,
      night_landings INTEGER,
      night_time TEXT,
      ifr_time TEXT,
      pic_time TEXT,
      co_pilot_time TEXT,
      dual_time TEXT,
      instructor_time TEXT,
      sim_type TEXT,
      sim_time TEXT,
      pic_name TEXT,
      remarks TEXT
    );

    CREATE UNIQUE INDEX IF NOT EXISTS logbook_uuid ON logbook(uuid);
  ''';

  static const viewLogbook = '''
    CREATE VIEW IF NOT EXISTS logbook_view
    AS
    SELECT uuid, date, substr(date,7,4) || substr(date,4,2) || substr(date,0,3) as m_date, departure_place, departure_time,
    arrival_place, arrival_time, aircraft_model, reg_name, se_time, me_time, mcc_time, total_time, iif(day_landings='',0,day_landings) as day_landings, iif(night_landings='',0,night_landings) as night_landings,
    night_time, ifr_time, pic_time, co_pilot_time, dual_time, instructor_time, sim_type, sim_time, pic_name, remarks
    FROM logbook;
  ''';

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'logbook.db');
    // await deleteDatabase(path);
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(tableLogbook);
      await db.execute(viewLogbook);
    });
  }

  Future getAllFlightRecords() async {
    final db = await database;
    return await db!.rawQuery(
      '''SELECT *
        FROM logbook_view
        ORDER BY m_date DESC;''',
    );
  }

  Future saveFlightRecord(Map<String, Object?> values, bool isNewFlight) async {
    final db = await database;

    if (isNewFlight) {
      return await db!.rawInsert('''INSERT INTO logbook
        (uuid, date, departure_place, departure_time, arrival_place,
        arrival_time, aircraft_model, reg_name, se_time, me_time,
        mcc_time, total_time, day_landings, night_landings, night_time,
        ifr_time, pic_time, co_pilot_time, dual_time, instructor_time,
        sim_type, sim_time, pic_name, remarks)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
        ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
        values['uuid'],
        values['date'],
        values['departure_place'],
        values['departure_time'],
        values['arrival_place'],
        values['arrival_time'],
        values['aircraft_model'],
        values['reg_name'],
        values['se_time'],
        values['me_time'],
        values['mcc_time'],
        values['total_time'],
        values['day_landings'],
        values['night_landings'],
        values['night_time'],
        values['ifr_time'],
        values['pic_time'],
        values['co_pilot_time'],
        values['dual_time'],
        values['instructor_time'],
        values['sim_type'],
        values['sim_time'],
        values['pic_name'],
        values['remarks'],
      ]);
    } else {
      return await db!.rawUpdate('''UPDATE logbook
        SET date = ?, departure_place = ?, departure_time = ?,
        arrival_place = ?, arrival_time = ?, aircraft_model = ?,
        reg_name = ?, se_time = ?, me_time = ?, mcc_time = ?,
        total_time = ?, day_landings = ?, night_landings = ?,
        night_time = ?, ifr_time = ?, pic_time = ?, co_pilot_time = ?,
        dual_time = ?, instructor_time = ?, sim_type = ?,
        sim_time = ?, pic_name = ?, remarks = ?
        WHERE uuid = ?
        ''', [
        values['date'],
        values['departure_place'],
        values['departure_time'],
        values['arrival_place'],
        values['arrival_time'],
        values['aircraft_model'],
        values['reg_name'],
        values['se_time'],
        values['me_time'],
        values['mcc_time'],
        values['total_time'],
        values['day_landings'],
        values['night_landings'],
        values['night_time'],
        values['ifr_time'],
        values['pic_time'],
        values['co_pilot_time'],
        values['dual_time'],
        values['instructor_time'],
        values['sim_type'],
        values['sim_time'],
        values['pic_name'],
        values['remarks'],
        values['uuid'],
      ]);
    }
  }

  Future deleteFlightRecord(String uuid) async {
    final db = await database;

    return await db!.rawDelete('''
      DELETE FROM logbook WHERE uuid = ?
      ''', [uuid]);
  }
}
