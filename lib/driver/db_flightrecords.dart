import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:web_logbook_mobile/helpers/helpers.dart';
import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/models/models.dart';

extension DBProviderFlightRecords on DBProvider {
  /// Returns all flight records from the database and orders them by date
  Future getAllFlightRecords() async {
    final db = await database;
    return await db!.rawQuery(
      '''SELECT * FROM logbook_view ORDER BY m_date DESC''',
    );
  }

  Future<int?> getFlightRecordsCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db!.rawQuery(
        '''SELECT COUNT(*) FROM logbook_view''',
      ),
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
