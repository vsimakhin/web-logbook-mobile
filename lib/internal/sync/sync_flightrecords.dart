import 'dart:convert';
import 'dart:io';

import 'package:web_logbook_mobile/models/models.dart';
import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_sync.dart';
import 'package:web_logbook_mobile/driver/db_flightrecords.dart';

import 'package:web_logbook_mobile/internal/sync/sync.dart';

extension FlightRecords on Sync {
  Future<dynamic> syncFlightRecords() async {
    dynamic error;

    // create http client
    final client = getClient();

    // get session id in case we need it
    await getSession(client);

    // first always sync deleted items, otherwise they will appear again
    // on one or other side
    error = await syncDeletedItems(client);
    if (error != null) {
      client.close();
      return error;
    }

    // sync flight records
    error = await _syncFlightRecords(client);
    if (error != null) {
      client.close();
      return error;
    }

    client.close();
    return error;
  }

  Future<dynamic> _syncFlightRecords(HttpClient client) async {
    dynamic error;

    final url = Uri.parse('${connect.url}${Sync.apiFlightRecords}');

    try {
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

    if (error != null) {
      // something wrong already
      return error;
    }

    List<FlightRecord> listFlightRecords = [];
    final rawFlightRecord = await DBProvider.db.getAllFlightRecords();
    for (var i = 0; i < rawFlightRecord.length; i++) {
      listFlightRecords.add(FlightRecord.fromData(rawFlightRecord[i]));
    }

    try {
      final payload = {'flight_records': listFlightRecords};
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

      error = null;
    } catch (e) {
      error = 'cannot upload records $e';
    }

    return error;
  }
}
