import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';

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
      remarks TEXT,
      update_time INTEGER
    );

    CREATE UNIQUE INDEX IF NOT EXISTS logbook_uuid ON logbook(uuid);
  ''';

  static const viewLogbook = '''
    CREATE VIEW IF NOT EXISTS logbook_view
    AS
    SELECT uuid, date,
      substr(date,7,4) || substr(date,4,2) || substr(date,0,3) as m_date,
      departure_place, departure_time, arrival_place, arrival_time,
      aircraft_model, reg_name, se_time, me_time, mcc_time, total_time,
      iif(day_landings='',0,day_landings) as day_landings,
      iif(night_landings='',0,night_landings) as night_landings,
      night_time, ifr_time, pic_time, co_pilot_time, dual_time, instructor_time,
      sim_type, sim_time, pic_name, remarks, update_time
    FROM logbook;
  ''';

  static const deletedItems = '''
    CREATE TABLE IF NOT EXISTS deleted_items (
        uuid TEXT PRIMARY_KEY,
        table_name TEXT NOT NULL,
        delete_time TEXT NOT NULL
    );
  ''';

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'logbook.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(tableLogbook);
        await db.execute(viewLogbook);
        await db.execute(deletedItems);
      },
      onOpen: (db) async {
        final oldItem = getEpochTime() - 7776000;

        await db.execute(
            '''DELETE FROM deleted_items WHERE delete_time < $oldItem''');
      },
    );
  }

  Future getAllFlightRecords() async {
    final db = await database;
    return await db!.rawQuery(
      '''SELECT *
        FROM logbook_view
        ORDER BY m_date DESC;''',
    );
  }

  Future getDeletedItems() async {
    final db = await database;
    return await db!.rawQuery(
      '''SELECT uuid, table_name, delete_time
        FROM deleted_items''',
    );
  }

  Future saveFlightRecord(FlightRecord fr) async {
    final db = await database;

    if (fr.isNew) {
      fr.uuid = const Uuid().v4();

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
        getEpochTime(),
      ]);
    } else {
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
        getEpochTime(),
        fr.uuid,
      ]);
    }
  }

  Future deleteFlightRecord(String uuid) async {
    final db = await database;

    await db!.rawDelete('''DELETE FROM logbook WHERE uuid = ?''', [uuid]);
    await db.rawInsert(
      '''
        INSERT INTO deleted_items (uuid, table_name, delete_time)
        VALUES(?, ?, ?)''',
      [uuid, 'logbook', getEpochTime()],
    );
  }

  Future syncFlightRecord(FlightRecord fr) async {
    final db = await database;

    final row = await db!.rawQuery(
      '''SELECT * FROM logbook WHERE uuid = ?''',
      [fr.uuid],
    );

    if (row.isNotEmpty) {
      final currentFR = FlightRecord.fromData(row[0]);
      if (currentFR.updateTime < fr.updateTime) {
        await db.rawUpdate('''UPDATE logbook
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
    } else {
      await db.rawInsert('''INSERT INTO logbook
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
  }

  Future syncDeletedItems(DeletedItem di) async {
    final db = await database;

    await db?.rawDelete(
        '''DELETE FROM ${di.tableName} WHERE uuid = ?''', [di.uuid]);
  }
}
