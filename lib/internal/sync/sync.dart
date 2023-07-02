import 'dart:convert';
import 'dart:io';

import 'package:web_logbook_mobile/models/models.dart';

import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_sync.dart';

// Sync class implements synchronization
class Sync {
  Sync({required this.connect});

  final Connect connect;

  static const apiLogin = '/login';
  static const apiDeleted = '/sync/deleted';
  static const apiFlightRecords = '/sync/flightrecords';
  static const apiAirports = '/sync/airports';

  late String session = '';

  HttpClient getClient() {
    final client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    return client;
  }

  // Gets session id in case the main app requires the authorization
  Future<void> getSession(HttpClient client) async {
    if (connect.auth) {
      final url = Uri.parse('${connect.url}$apiLogin');
      final payload = jsonEncode({
        'login': connect.username,
        'connect.password': connect.password,
      });

      final req = await client.postUrl(url);
      req.headers.contentType = ContentType.json;
      req.followRedirects = false;
      req.write(payload);
      final res = await req.close();
      final sessionCookie = res.headers['set-cookie'];
      session = sessionCookie![0].split(';')[0].split('=')[1];
    }
  }

  Future<dynamic> syncDeletedItems(HttpClient client) async {
    dynamic error;
    final url = Uri.parse('${connect.url}${Sync.apiDeleted}');

    // download deleted items
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
          final di = DeletedItem.fromData(json[i] as Map<String, dynamic>);
          await DBProvider.db.processDeletedItems(di);
        }

        error = null;
      } else {
        error = 'response code ${res.statusCode}';
      }
    } catch (e) {
      error = 'cannot sync deleted items - $e';
    }

    if (error != null) {
      // something wrong already
      return error;
    }

    // upload deleted items
    List<DeletedItem> listDeletedItems = [];
    final rawDeletedItems = await DBProvider.db.getDeletedItems();
    for (var i = 0; i < rawDeletedItems.length; i++) {
      listDeletedItems.add(DeletedItem.fromData(rawDeletedItems[i]));
    }

    try {
      final payload = {'deleted_items': listDeletedItems};
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
}
