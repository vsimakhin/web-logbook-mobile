import 'dart:convert';
import 'dart:io';

import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_airports.dart';
import 'package:web_logbook_mobile/internal/sync/sync.dart';

extension SyncAirports on Sync {
  // Downloads airports from the main app
  Future<dynamic> downloadAirports() async {
    dynamic result;

    // create http client and get session id
    final client = getClient();
    await getSession(client);

    try {
      final url = Uri.parse('${connect.url}${Sync.apiAirports}');
      final req = await client.getUrl(url);

      if (connect.auth) {
        req.cookies.add(Cookie('session', session));
      }

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode == 200) {
        final json = jsonDecode(body);
        result = await DBProvider.db.updateAirportsDB(json);
      } else {
        result = 'response code ${res.statusCode}';
      }
    } catch (e) {
      result = 'cannot download records $e';
    }

    client.close();

    return result;
  }
}
