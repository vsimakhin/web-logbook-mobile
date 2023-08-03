import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_flightrecords.dart';
import 'package:web_logbook_mobile/models/models.dart';

extension DBProviderSync on DBProvider {
  /// A function that synchronizes a flight record with the local database.
  Future syncFlightRecord(FlightRecord fr) async {
    final db = await database;

    final row = await db!.rawQuery(
      '''SELECT * FROM logbook WHERE uuid = ?''',
      [fr.uuid],
    );

    if (row.isNotEmpty) {
      final currentFR = FlightRecord.fromData(row[0]);
      if (currentFR.updateTime < fr.updateTime) {
        await updateFlightRecord(fr);
      }
    } else {
      await insertFlightRecord(fr);
    }
  }

  /// Deletes the item with the given UUID from the corresponding table
  /// in the database.
  Future processDeletedItems(DeletedItem di) async {
    final db = await database;

    await db?.rawDelete(
      '''DELETE FROM ${di.tableName} WHERE uuid = ?''',
      [di.uuid],
    );
  }

  /// Removed records from the deleted_items table once they are uploaded
  /// to the main app. This logic might be changed in future, but for now
  /// will keep like this
  Future cleanDeletedItems() async {
    final db = await database;

    await db?.rawDelete('''DELETE FROM deleted_items''');
  }

  /// Returns all removed items
  Future<List<DeletedItem>> getDeletedItems() async {
    List<DeletedItem> deletedItems = [];

    final db = await database;
    final raw = await db!.rawQuery(
      '''SELECT uuid, table_name, delete_time FROM deleted_items''',
    );

    for (var i = 0; i < raw.length; i++) {
      deletedItems.add(DeletedItem.fromData(raw[i]));
    }

    return deletedItems;
  }

  Future getLocalAttachmentIds() async {
    List<String> attachmentIds = [];

    final db = await database;

    final raw = await db!.rawQuery(
      '''SELECT uuid FROM attachments''',
    );

    for (var i = 0; i < raw.length; i++) {
      attachmentIds.add(raw[i]['uuid'] as String);
    }

    return attachmentIds;
  }
}
