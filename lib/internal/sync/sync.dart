import 'dart:convert';
import 'dart:io';

import 'package:web_logbook_mobile/models/models.dart';

import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_sync.dart';

// Sync class implements synchronization
class Sync {
  Sync({required this.connect}) {
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }

  final Connect connect;

  static const apiLogin = '/login';
  static const apiDeleted = '/sync/deleted';
  static const apiFlightRecords = '/sync/flightrecords';
  static const apiAirports = '/sync/airports';
  static const apiAttachments = '/sync/attachments/';

  late String session = '';

  HttpClient client = HttpClient();

  // Gets session id in case the main app requires the authorization
  Future<void> getSession() async {
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

  // prepare the http client GET request and return the result
  Future<(dynamic result, dynamic error)> syncGet(Uri url) async {
    dynamic error;
    dynamic result;

    try {
      final req = await client.getUrl(url);

      if (connect.auth) {
        req.cookies.add(Cookie('session', session));
      }

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode == 200) {
        final json = jsonDecode(body);

        result = json;
        error = null;
      } else {
        error = 'response code ${res.statusCode}';
      }
    } catch (e) {
      error = e;
    }

    return (result, error);
  }

  // prepare the http client POST request and return the error if any
  Future<dynamic> syncPost(Uri url, Object payload) async {
    dynamic error;
    String jsonEncoded;

    try {
      jsonEncoded = jsonEncode(payload);
    } catch (e) {
      return 'cannot encode payload $e';
    }

    try {
      final req = await client.postUrl(url);

      if (connect.auth) {
        req.cookies.add(Cookie('session', session));
      }

      req.headers.contentType = ContentType.json;
      req.write(jsonEncoded);
      final res = await req.close();

      if (res.statusCode != 200) {
        error = 'response code ${res.statusCode}';
      }

      error = null;
    } catch (e) {
      error = e;
    }

    return error;
  }

  // syncs deleted records with main app
  Future<dynamic> syncDeletedItems() async {
    dynamic error;
    dynamic json;

    final url = Uri.parse('${connect.url}${Sync.apiDeleted}');

    // download deleted items
    (json, error) = await syncGet(url);
    if (error != null) {
      return 'cannot download deleted items - $error';
    }

    for (var i = 0; i < json.length; i++) {
      final di = DeletedItem.fromData(json[i] as Map<String, dynamic>);
      await DBProvider.db.processDeletedItems(di);
    }

    // upload deleted items
    final deletedItems = await DBProvider.db.getDeletedItems();
    final payload = {'deleted_items': deletedItems};
    error = await syncPost(url, payload);

    if (error != null) {
      return 'cannot upload deleted items - $error';
    } else {
      await DBProvider.db.cleanDeletedItems();
    }

    return null;
  }
}
