import 'package:web_logbook_mobile/driver/db_attachments.dart';
import 'package:web_logbook_mobile/models/models.dart';
import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_sync.dart';
import 'package:web_logbook_mobile/driver/db_flightrecords.dart';

import 'package:web_logbook_mobile/internal/sync/sync.dart';

extension FlightRecords on Sync {
  Future<dynamic> syncFlightRecords() async {
    dynamic error;

    // get session id in case we need it
    await getSession();

    // first always sync deleted items, otherwise they will appear again
    // on one or other side
    error = await syncDeletedItems();
    if (error != null) {
      client.close();
      return error;
    }

    // sync flight records
    error = await _syncFlightRecords();
    if (error != null) {
      client.close();
      return error;
    }

    // sync attachments
    error = await _syncAttachments();
    if (error != null) {
      client.close();
      return error;
    }

    client.close();
    return error;
  }

  Future<dynamic> _syncFlightRecords() async {
    dynamic error;
    dynamic json;

    final url = Uri.parse('${connect.url}${Sync.apiFlightRecords}');

    // download flight records
    (json, error) = await syncGet(url);
    if (error != null) {
      return 'cannot download flight records - $error';
    }

    for (var i = 0; i < json.length; i++) {
      await DBProvider.db.syncFlightRecord(FlightRecord.fromData(json[i]));
    }

    // upload flight records
    final flightRecords = await DBProvider.db.getAllFlightRecords(rawFormat: false) as List<FlightRecord>;
    final payload = {'flight_records': flightRecords};
    error = await syncPost(url, payload);
    if (error != null) {
      return 'cannot upload flight records - $error';
    }

    return null;
  }

  Future<dynamic> _syncAttachments() async {
    dynamic error;
    dynamic json;

    List<String> mainAppAttachmentIds = [];
    List<String> myAttachmentIds = [];

    // get the list of attachments from the main app
    final url = Uri.parse('${connect.url}${Sync.apiAttachments}all');
    (json, error) = await syncGet(url);
    if (error != null) {
      return 'cannot download records - $error';
    }

    for (var i = 0; i < json.length; i++) {
      mainAppAttachmentIds.add(Attachment.fromData(json[i]).uuid);
    }

    // get list of local attachments
    myAttachmentIds = await DBProvider.db.getLocalAttachmentIds();

    // check if we need to download attachments from the main app
    for (var i = 0; i < mainAppAttachmentIds.length; i++) {
      if (!myAttachmentIds.contains(mainAppAttachmentIds[i])) {
        final url = Uri.parse('${connect.url}${Sync.apiAttachments}${mainAppAttachmentIds[i]}');
        (json, error) = await syncGet(url);
        if (error != null) {
          return 'cannot get attachment ${mainAppAttachmentIds[i]} - $error';
        }

        if (!json.isEmpty) {
          final attachment = Attachment.fromData(json);
          await DBProvider.db.insertAttachmentRecord(attachment);
        }
      }
    }

    // check if we need to upload attachments to the main app
    for (var i = 0; i < myAttachmentIds.length; i++) {
      if (!mainAppAttachmentIds.contains(myAttachmentIds[i])) {
        // upload
        final url = Uri.parse('${connect.url}${Sync.apiAttachments}upload');

        final att = await DBProvider.db.getAttachmentById(myAttachmentIds[i]);
        if (!att.isEmpty) {
          error = await syncPost(url, att);
          if (error != null) {
            return 'cannot upload attachment ${att.uuid} - $error';
          }
        }
      }
    }

    return error;
  }
}
