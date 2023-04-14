import 'package:flutter/material.dart';
import 'package:web_logbook_mobile/models/models.dart';

import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_flightrecords.dart';

import 'package:web_logbook_mobile/pages/flight/flight.dart';

class FlightRecordsPage extends StatefulWidget {
  const FlightRecordsPage({Key? key}) : super(key: key);

  @override
  State<FlightRecordsPage> createState() => _FlightRecordsPageState();
}

class _FlightRecordsPageState extends State<FlightRecordsPage> {
  List<Map<String, dynamic>> _dataList = [];

  static const double headingRowH = 40;
  static const double dataRowH = 35;

  bool wideScreen = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataList = await DBProvider.db.getAllFlightRecords();

    setState(() {
      _dataList = dataList;
    });
  }

  List<DataColumn> _getColumns() {
    if (wideScreen) {
      return const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Departure')),
        DataColumn(label: Text('Arrival')),
        DataColumn(label: Text('Aircraft')),
        DataColumn(label: Text('Total')),
        DataColumn(label: Text('PIC Name')),
        DataColumn(label: Text('Landings')),
        DataColumn(label: Text('SIM')),
      ];
    } else {
      return const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Departure')),
        DataColumn(label: Text('Arrival')),
        DataColumn(label: Text('Aircraft')),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.connecting_airports),
            SizedBox(width: 10),
            Text('Flight Records'),
          ],
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        wideScreen = (constraints.maxWidth > 400);

        final int rowsPerPage =
            (constraints.maxHeight - headingRowH - 70) ~/ dataRowH + 1;

        if (_dataList.isNotEmpty) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PaginatedDataTable(
                  columns: _getColumns(),
                  source: _FlightRecordsSource(
                    dataList: _dataList,
                    wideScreen: wideScreen,
                    context: context,
                    callback: () {
                      _loadData();
                    },
                  ),
                  rowsPerPage: rowsPerPage,
                  headingRowHeight: headingRowH,
                  dataRowMinHeight: dataRowH,
                  dataRowMaxHeight: dataRowH,
                  columnSpacing: 20,
                  horizontalMargin: 10,
                  showFirstLastButtons: true,
                  showCheckboxColumn: false,
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No Flight Records'));
        }
      }),
    );
  }
}

/// Datasource for the Flight Record PaginatedDataTable
class _FlightRecordsSource extends DataTableSource {
  _FlightRecordsSource({
    required this.dataList,
    required this.wideScreen,
    required this.context,
    required this.callback,
  });

  List<Map<String, dynamic>> dataList;
  final bool wideScreen;
  final BuildContext context;
  final void Function() callback;

  @override
  DataRow getRow(int index) {
    final fr = FlightRecord.fromData(dataList[index]);

    List<DataCell> cells = [];

    if (wideScreen) {
      cells = [
        DataCell(Text(fr.date)),
        DataCell(Text('${fr.departurePlace} ${fr.departureTime}')),
        DataCell(Text('${fr.arrivalPlace} ${fr.arrivalTime}')),
        DataCell(Text('${fr.aircraftModel} ${fr.aircraftReg}')),
        DataCell(Text(fr.timeTT)),
        DataCell(Text(fr.picName)),
        DataCell(Text('${fr.dayLandings}/${fr.nightLandings}')),
        DataCell(Text('${fr.simType} ${fr.simTime}')),
      ];
    } else {
      // in case it's a SIM session, show SIM Type
      String aircraftInfo;
      if (fr.departurePlace == '' && fr.arrivalPlace == '') {
        aircraftInfo = fr.simType;
      } else {
        aircraftInfo = '${fr.aircraftModel} ${fr.aircraftReg}';
      }

      cells = [
        DataCell(Text(fr.date)),
        DataCell(Text('${fr.departurePlace} ${fr.departureTime}')),
        DataCell(Text('${fr.arrivalPlace} ${fr.arrivalTime}')),
        DataCell(Text(aircraftInfo)),
      ];
    }

    return DataRow(
      cells: cells,
      onSelectChanged: (_) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlightPage(flightRecord: fr),
            )).then((value) {
          if (value != null) {
            if (value) {
              callback();
            }
          }
        });
      },
    );
  }

  @override
  int get rowCount => dataList.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
