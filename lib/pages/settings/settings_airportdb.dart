import 'package:flutter/material.dart';
import 'package:web_logbook_mobile/models/models.dart';
import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_airports.dart';
import 'package:web_logbook_mobile/internal/sync/sync.dart';
import 'package:web_logbook_mobile/internal/sync/sync_airports.dart';
import 'package:web_logbook_mobile/helpers/helpers.dart';

class AirportDB extends StatefulWidget {
  const AirportDB({Key? key, required this.connect}) : super(key: key);

  final Connect connect;

  @override
  State<AirportDB> createState() => _AirportDBState();
}

class _AirportDBState extends State<AirportDB> {
  int _airports = 0;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _getAirportsCount();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.local_airport),
        const SizedBox(width: 15),
        Text('Airports in database: $_airports'),
        const Spacer(),
        Visibility(
          visible: _isUpdating,
          child: const CircularProgressIndicator(),
        ),
        const Spacer(),
        ElevatedButton(
          child: const Text('Update'),
          onPressed: () {
            if (_isUpdating) return;

            _dowloadAirports();
          },
        )
      ],
    );
  }

  Future<void> _getAirportsCount() async {
    final count = await DBProvider.db.getAirportsCount();
    setState(() {
      _airports = count ?? 0;
    });
  }

  Future<void> _dowloadAirports() async {
    final connect = widget.connect;

    setState(() => _isUpdating = true);

    final res = await Sync(connect: connect).downloadAirports();

    setState(() {
      _isUpdating = false;
      _getAirportsCount();
    });

    if (!mounted) return;

    if (res == null) {
      showInfo(context, 'Airports downloaded');
    } else {
      showError(context, 'Error downloading airports: $res');
    }
  }
}
