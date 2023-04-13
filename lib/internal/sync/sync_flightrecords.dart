import 'dart:convert';
import 'dart:io';

import 'package:web_logbook_mobile/models/models.dart';
import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_sync.dart';
import 'package:web_logbook_mobile/driver/db_flightrecords.dart';

import 'package:web_logbook_mobile/internal/sync/sync.dart';

extension SyncFlightRecords on Sync {
  // Main Sync function
  Future<dynamic> runSync() async {
    dynamic error;

    // create http client
    final client = getClient();

    // get session id in case we need it
    await getSession(client);

    // first always sync deleted items, otherwise they will appear again
    // on one or other side
    error = await _syncDeletedItems(client);
    if (error != null) {
      client.close();
      return error;
    }

    // Upload records. The main app will process deleted records in
    // the beginning, and then will check the changed
    error = await _syncUploadRecords(client);
    if (error != null) {
      client.close();
      return error;
    }

    // Dowload the flight records and check the changes
    error = await _syncDownloadRecords(client);
    if (error != null) {
      client.close();
      return error;
    }

    client.close();
    return error;
  }

  // Syncs deleted items
  Future<dynamic> _syncDeletedItems(HttpClient client) async {
    dynamic error;

    try {
      final url = Uri.parse('${connect.url}${Sync.apiDeleted}');
      final req = await client.getUrl(url);

      if (connect.auth) {
        req.cookies.add(Cookie('session', session));
      }

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode == 200) {
        final json = jsonDecode(body);

        for (var i = 0; i < json.length; i++) {
          final di = DeletedItem.fromData(json[i] as Map<String, dynamic>);
          await DBProvider.db.syncDeletedItems(di);
        }

        error = null;
      } else {
        error = 'response code ${res.statusCode}';
      }
    } catch (e) {
      error = 'cannot sync deleted items - $e';
    }

    return error;
  }

  // Uploads flight records and deleted items to the main app
  Future<dynamic> _syncUploadRecords(HttpClient client) async {
    dynamic error;

    List<FlightRecord> listFlightRecords = [];
    final rawFlightRecord = await DBProvider.db.getAllFlightRecords();
    for (var i = 0; i < rawFlightRecord.length; i++) {
      listFlightRecords.add(FlightRecord.fromData(rawFlightRecord[i]));
    }

    List<DeletedItem> listDeletedItems = [];
    final rawDeletedItems = await DBProvider.db.getDeletedItems();
    for (var i = 0; i < rawDeletedItems.length; i++) {
      listDeletedItems.add(DeletedItem.fromData(rawDeletedItems[i]));
    }

    try {
      final payload = {
        'flight_records': listFlightRecords,
        'deleted_items': listDeletedItems
      };

      final url = Uri.parse('${connect.url}${Sync.apiUpload}');
      final req = await client.postUrl(url);

      if (connect.auth) {
        req.cookies.add(Cookie('session', session));
      }

      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(payload));
      final res = await req.close();

      if (res.statusCode != 200) {
        error = 'response code ${res.statusCode}';
      }

      // once we uploaded deleted items we don't need them anymore
      await DBProvider.db.cleanDeletedItems();

      error = null;
    } catch (e) {
      error = 'cannot upload records $e';
    }

    return error;
  }

  // Downloads the flight records from the main app
  Future<dynamic> _syncDownloadRecords(HttpClient client) async {
    dynamic error;

    try {
      final url = Uri.parse('${connect.url}${Sync.apiDownload}');
      final req = await client.getUrl(url);

      if (connect.auth) {
        req.cookies.add(Cookie('session', session));
      }

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode == 200) {
        final json = jsonDecode(body);
        for (var i = 0; i < json.length; i++) {
          await DBProvider.db.syncFlightRecord(FlightRecord.fromData(json[i]));
        }
        error = null;
      } else {
        error = 'response code ${res.statusCode}';
      }
    } catch (e) {
      error = 'cannot download records $e';
    }

    return error;
  }
}
