import 'dart:typed_data';
import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/models/models.dart';

import '../helpers/helpers.dart';

extension DBProviderAttachments on DBProvider {
  // insert attachment record
  Future<dynamic> insertAttachmentRecord(Attachment att) async {
    final db = await database;

    return await db!.rawInsert('''INSERT INTO attachments
        (uuid, record_id, document_name, document) VALUES (?, ?, ?, ?)
        ''', [att.uuid, att.recordId, att.documentName, att.document]);
  }

  // returns attachment by id
  Future<dynamic> getAttachmentById(String id, {bool rawFormat = true}) async {
    final db = await database;
    if (db == null) return [];

    // android has a limit of ~2MB for the cursor window
    // which doesn't allow to get the whole attachment in one select if the size
    // is bigger than this limit
    const limit = 2 * 1024 * 1024;

    final raw = await db.rawQuery(
        '''SELECT uuid, record_id, document_name, length(document) as ll FROM attachments WHERE uuid = ?''', [id]);

    final fieldLength = raw[0]['ll'] as int;
    var document = BytesBuilder();

    if (fieldLength <= limit) {
      // no need to go through the chunks
      final result = await db.rawQuery('''SELECT document FROM attachments WHERE uuid = ?''', [raw[0]['uuid']]);
      document.add(result[0]['document'] as List<int>);
    } else {
      // split to chunks
      int cursor = 1;
      int length = limit * 2;

      while (length >= limit) {
        final result = await db.rawQuery(
            '''SELECT substr(document, $cursor, $limit) as chunk, length(substr(document, $cursor, $limit)) as ll FROM attachments WHERE uuid = ?''',
            [raw[0]['uuid']]);

        length = result[0]['ll'] as int;
        cursor += length;

        document.add(result[0]['chunk'] as List<int>);
      }
    }

    final rawAttachment = {
      'uuid': raw[0]['uuid'],
      'record_id': raw[0]['record_id'],
      'document_name': raw[0]['document_name'],
      'document': document.toBytes()
    };

    if (rawFormat) {
      return rawAttachment;
    } else {
      return Attachment.fromMap(rawAttachment);
    }
  }

  // returns all attachments for the flight record
  Future<List<Attachment>> getAttachmentsForFlightRecord(String id) async {
    List<Attachment> attachments = [];

    final db = await database;
    final raw = await db!.rawQuery(
        '''SELECT uuid, record_id, document_name, length(document) as ll FROM attachments WHERE record_id = ?''', [id]);

    for (var i = 0; i < raw.length; i++) {
      final rawAttachment = await getAttachmentById(raw[i]['uuid'] as String);
      attachments.add(Attachment.fromMap(rawAttachment));
    }

    return attachments;
  }

  // delete attachment
  Future<dynamic> deleteAttachment(String uuid) async {
    final db = await database;

    final res = await db!.rawDelete('''DELETE FROM attachments WHERE uuid = ?''', [uuid]);

    if (res == 0) return 'no record with uuid $uuid found';

    await db.rawInsert(
      '''INSERT INTO deleted_items (uuid, table_name, delete_time)
        VALUES(?, ?, ?)''',
      [uuid, 'attachments', getEpochTime()],
    );

    return null;
  }
}
