import 'package:flutter/material.dart';
import 'db.dart';
import 'flight.dart';

class FlightRecordsPage extends StatefulWidget {
  const FlightRecordsPage({Key? key}) : super(key: key);

  @override
  State<FlightRecordsPage> createState() => _FlightRecordsPageState();
}

class _FlightRecordsPageState extends State<FlightRecordsPage> {
  List<Map<String, dynamic>> _dataList = [];

  static const double headingRowHeight = 40;
  static const double dataRowHeight = 35;

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
        final bool shouldBeWideTable = (constraints.maxWidth > 400);
        final int rowsPerPage =
            ((constraints.maxHeight - headingRowHeight - 70) ~/ dataRowHeight)
                    .toInt() +
                1;
        if (wideScreen != shouldBeWideTable) {
          wideScreen = shouldBeWideTable;
        }

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
                  headingRowHeight: headingRowHeight,
                  dataRowMinHeight: dataRowHeight,
                  dataRowMaxHeight: dataRowHeight,
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
    final row = dataList[index];
    List<DataCell> cells = [];

    if (wideScreen) {
      cells = [
        DataCell(Text(row['date'] ?? '')),
        DataCell(Text('${row['departure_place']} ${row['departure_time']}')),
        DataCell(Text('${row['arrival_place']} ${row['arrival_time']}')),
        DataCell(Text('${row['aircraft_model']} ${row['reg_name']}')),
        DataCell(Text('${row['total_time']}')),
        DataCell(Text('${row['pic_name']}')),
        DataCell(Text('${row['day_landings']}/${row['night_landings']}')),
        DataCell(Text('${row['sim_type']} ${row['sim_time']}')),
      ];
    } else {
      cells = [
        DataCell(Text(row['date'] ?? '')),
        DataCell(Text('${row['departure_place']} ${row['departure_time']}')),
        DataCell(Text('${row['arrival_place']} ${row['arrival_time']}')),
        DataCell(Text('${row['aircraft_model']} ${row['reg_name']}')),
      ];
    }

    return DataRow(
      cells: cells,
      onSelectChanged: (_) {
        // open flight page here
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlightPage(flightRecord: {
                'uuid': row['uuid'],
                'date': row['date'],
                'departure_place': row['departure_place'],
                'departure_time': row['departure_time'],
                'arrival_place': row['arrival_place'],
                'arrival_time': row['arrival_time'],
                'aircraft_model': row['aircraft_model'],
                'reg_name': row['reg_name'],
                'se_time': row['se_time'],
                'me_time': row['me_time'],
                'mcc_time': row['mcc_time'],
                'total_time': row['total_time'],
                'day_landings': row['day_landings'],
                'night_landings': row['night_landings'],
                'night_time': row['night_time'],
                'ifr_time': row['ifr_time'],
                'pic_time': row['pic_time'],
                'co_pilot_time': row['co_pilot_time'],
                'dual_time': row['dual_time'],
                'instructor_time': row['instructor_time'],
                'sim_type': row['sim_type'],
                'sim_time': row['sim_time'],
                'pic_name': row['pic_name'],
                'remarks': row['remarks'],
              }),
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
