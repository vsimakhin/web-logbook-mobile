import 'package:sqflite/sqflite.dart';

import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/models/models.dart';

// extension Airports on DBProvider
extension DBProviderAirports on DBProvider {
  /// Returns airport by ICAO or IATA code
  Future<List<Map<String, Object?>>> getAirport(String id) async {
    final db = await database;
    if (db == null) return [];

    return await db.rawQuery(
      '''SELECT * FROM airports WHERE icao = ? OR iata = ?''',
      [id, id],
    );
  }

  /// Returns amount of airports in the database
  Future<int?> getAirportsCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db!.rawQuery(
        '''SELECT COUNT(*) FROM airports''',
      ),
    );
  }

  /// Updtaes the airport database with the provided JSON data
  Future updateAirportsDB(dynamic json) async {
    const dropIndexes = '''
      DROP INDEX IF EXISTS airports_icao;
      DROP INDEX IF EXISTS airports_iata;
    ''';
    const truncateTable = '''DELETE FROM airports''';
    const createIndexes = '''
      CREATE UNIQUE INDEX IF NOT EXISTS airports_icao ON airports(icao);
      CREATE INDEX IF NOT EXISTS airports_iata ON airports(iata);
    ''';

    final db = await database;
    if (db == null) return 'cannot initialize connection to database';

    if (json.length == 0) {
      // nothing to do
      return 'response is empty';
    }

    // drop indexes, truncate table
    await db.execute(dropIndexes);
    await db.execute(truncateTable);

    for (var i = 0; i < json.length; i++) {
      final airport = Airport.fromData(json[i]);

      await db.rawInsert(
        '''INSERT INTO airports (icao, iata, name, city, country, elevation, lat, lon)
				 VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
        [
          airport.icao,
          airport.iata,
          airport.name,
          airport.city,
          airport.country,
          airport.elevation,
          airport.lat,
          airport.lon,
        ],
      );
    }

    // create indexes
    await db.execute(createIndexes);

    return null;
  }
}
