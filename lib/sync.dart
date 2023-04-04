import 'models.dart';
import 'db.dart';
import 'dart:convert';
import 'dart:io';

// Sync class implements synchronization
class Sync {
  Sync({
    required this.serverAddress,
    required this.useAuthentication,
    required this.username,
    required this.password,
  });

  final String serverAddress;
  final bool useAuthentication;
  final String username;
  final String password;

  static const apiLogin = '/login';
  static const apiDeleted = '/sync/deleted';
  static const apiUpload = '/sync/upload';
  static const apiDownload = '/sync/data';

  late String session = '';
  String error = '';

  // Gets session id in case the main app requires the authorization
  Future<void> _getSession(HttpClient client) async {
    if (useAuthentication) {
      final url = Uri.parse('$serverAddress$apiLogin');
      final payload = jsonEncode({
        'login': username,
        'password': password,
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

  // Syncs deleted items
  Future<void> _syncDeletedItems(HttpClient client) async {
    try {
      final url = Uri.parse('$serverAddress$apiDeleted');
      final req = await client.getUrl(url);

      if (useAuthentication) {
        req.cookies.add(Cookie('session', session));
      }

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode == 200) {
        final json = jsonDecode(body);

        for (var i = 0; i < json.length; i++) {
          await DBProvider.db.syncDeletedItems(DeletedItem.fromJson(json[i]));
        }
      } else {
        error = 'response code ${res.statusCode}';
      }
    } catch (e) {
      error = 'cannot sync deleted items - $e';
    }
  }

  // Uploads flight records and deleted items to the main app
  Future<void> _syncUploadRecords(HttpClient client) async {
    List<FlightRecord> listFlightRecords = [];
    final rawFlightRecord = await DBProvider.db.getAllFlightRecords();
    for (var i = 0; i < rawFlightRecord.length; i++) {
      listFlightRecords.add(FlightRecord.fromData(rawFlightRecord[i]));
    }

    List<DeletedItem> listDeletedItems = [];
    final rawDeletedItems = await DBProvider.db.getDeletedItems();
    for (var i = 0; i < rawDeletedItems.length; i++) {
      listDeletedItems.add(DeletedItem.fromJson(rawDeletedItems[i]));
    }

    try {
      final payload = {
        'flight_records': listFlightRecords,
        'deleted_items': listDeletedItems
      };

      final url = Uri.parse('$serverAddress$apiUpload');
      final req = await client.postUrl(url);

      if (useAuthentication) {
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
    } catch (e) {
      error = 'cannot upload records $e';
    }
  }

  // Downloads the flight records from the main app
  Future<void> _syncDownloadRecords(HttpClient client) async {
    try {
      final url = Uri.parse('$serverAddress$apiDownload');
      final req = await client.getUrl(url);

      if (useAuthentication) {
        req.cookies.add(Cookie('session', session));
      }

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode == 200) {
        final json = jsonDecode(body);
        for (var i = 0; i < json.length; i++) {
          await DBProvider.db.syncFlightRecord(FlightRecord.fromJson(json[i]));
        }
      } else {
        error = 'response code ${res.statusCode}';
      }
    } catch (e) {
      error = 'cannot download records $e';
    }
  }

  // Main Sync function
  Future<String> runSync() async {
    // create http client
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    // get session id in case we need it
    await _getSession(client);

    // first always sync deleted items, otherwise they will appear again
    // on one or other side
    await _syncDeletedItems(client);
    if (error != '') {
      client.close();
      return error;
    }

    // Upload records. The main app will process deleted records in
    // the beginning, and then will check the changed
    await _syncUploadRecords(client);
    if (error != '') {
      client.close();
      return error;
    }

    // Dowload the flight records and check the changes
    await _syncDownloadRecords(client);
    if (error != '') {
      client.close();
      return error;
    }

    client.close();
    return error;
  }
}
