import 'package:flutter/material.dart';
import 'package:web_logbook_mobile/helpers/helpers.dart';
import 'package:web_logbook_mobile/main.dart';
import 'package:web_logbook_mobile/driver/db.dart';

class DeleteFlightRecordButton extends StatelessWidget {
  const DeleteFlightRecordButton(
      {super.key, required this.uuid, required this.flightRecordName});

  final String flightRecordName;
  final String uuid;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Delete Flight Record?'),
          content: Text('Delete Flight Record $flightRecordName?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes, delete.'),
              onPressed: () async => await _onPressed(context),
            ),
            TextButton(
              child: const Text('No, keep it.'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      child: const Text('Delete'),
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    final error = await DBProvider.db.deleteFlightRecord(uuid);

    if (!context.mounted) return;

    if (error != null) {
      showError(context, error);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyApp()),
        (route) => false,
      );
    }
  }
}
