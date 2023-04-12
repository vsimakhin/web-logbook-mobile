import 'dart:convert';
import 'dart:io';

import 'package:web_logbook_mobile/models/models.dart';

// Sync class implements synchronization
class Sync {
  Sync({required this.connect});

  final Connect connect;

  static const apiLogin = '/login';
  static const apiDeleted = '/sync/deleted';
  static const apiUpload = '/sync/upload';
  static const apiDownload = '/sync/data';
  static const apiAirports = '/sync/airports';

  late String session = '';

  HttpClient getClient() {
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

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
}
