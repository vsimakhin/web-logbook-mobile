import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_airports.dart';
import 'package:web_logbook_mobile/internal/sync/sync.dart';

extension SyncAirports on Sync {
  // Downloads airports from the main app
  Future<dynamic> downloadAirports() async {
    dynamic error;
    dynamic json;

    await getSession();

    final url = Uri.parse('${connect.url}${Sync.apiAirports}');
    (json, error) = await syncGet(url);
    if (error != null) {
      return error;
    }

    error = await DBProvider.db.updateAirportsDB(json);
    if (error != null) {
      return error;
    }

    return null;
  }
}
