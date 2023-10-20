import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_flightrecords.dart';

import 'package:web_logbook_mobile/models/models.dart';
import 'package:web_logbook_mobile/pages/stats/stats_tablerow.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  FlightRecord month = FlightRecord();
  FlightRecord year = FlightRecord();
  FlightRecord all = FlightRecord();

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bar_chart),
            SizedBox(width: 10),
            Text('Stats'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                },
                children: [
                  StatsTableRow(
                    name: 'Stats',
                    values: const ['This Month', 'This\nYear', 'All time'],
                    isHeader: true,
                  ),
                  StatsTableRow(
                    name: 'Total time',
                    values: [month.timeTT, year.timeTT, all.timeTT],
                  ),
                  StatsTableRow(
                    name: 'Single Engine',
                    values: [month.timeSE, year.timeSE, all.timeSE],
                  ),
                  StatsTableRow(
                    name: 'Multi Engine',
                    values: [month.timeME, year.timeME, all.timeME],
                  ),
                  StatsTableRow(
                    name: 'MCC',
                    values: [month.timeMCC, year.timeMCC, all.timeMCC],
                  ),
                  StatsTableRow(
                    name: 'Night',
                    values: [month.timeNight, year.timeNight, all.timeNight],
                  ),
                  StatsTableRow(
                    name: 'IFR',
                    values: [month.timeIFR, year.timeIFR, all.timeIFR],
                  ),
                  StatsTableRow(
                    name: 'PIC',
                    values: [month.timePIC, year.timePIC, all.timePIC],
                  ),
                  StatsTableRow(
                    name: 'Co Pilot',
                    values: [month.timeCOP, year.timeCOP, all.timeCOP],
                  ),
                  StatsTableRow(
                    name: 'Dual',
                    values: [month.timeDual, year.timeDual, all.timeDual],
                  ),
                  StatsTableRow(
                    name: 'Instructor',
                    values: [month.timeInstr, year.timeInstr, all.timeInstr],
                  ),
                  StatsTableRow(
                    name: 'Simulator',
                    values: [month.simTime, year.simTime, all.simTime],
                  ),
                  StatsTableRow(
                    name: 'Day Landings',
                    values: [month.dayLandings.toString(), year.dayLandings.toString(), all.dayLandings.toString()],
                  ),
                  StatsTableRow(
                    name: 'Night Landings',
                    values: [
                      month.nightLandings.toString(),
                      year.nightLandings.toString(),
                      all.nightLandings.toString()
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _calculateTotals() async {
    FlightRecord totals = _addTotals(FlightRecord(), FlightRecord());
    FlightRecord totalsMonth = _addTotals(FlightRecord(), FlightRecord());
    FlightRecord totalsYear = _addTotals(FlightRecord(), FlightRecord());

    // get all flight records
    final frs = await DBProvider.db.getAllFlightRecords();

    if (frs.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final beginningOfMonth = DateTime(now.year, now.month, 1);
    final beginningOfYear = DateTime(now.year, 1, 1);
    final fmtMonthDate = DateFormat('yyyyMMdd').format(beginningOfMonth);
    final fmtYearDate = DateFormat('yyyyMMdd').format(beginningOfYear);

    for (var i = 0; i < frs.length; i++) {
      final fr = FlightRecord.fromData(frs[i]);
      final mdate = frs[i]['m_date'] as String;

      // this month
      if (mdate.compareTo(fmtMonthDate) >= 0) {
        totalsMonth = _addTotals(totalsMonth, fr);
      }
      // this year
      if (mdate.compareTo(fmtYearDate) >= 0) {
        totalsYear = _addTotals(totalsYear, fr);
      }
      // all totals
      totals = _addTotals(totals, fr);
    }

    setState(() {
      month = totalsMonth;
      year = totalsYear;
      all = totals;
    });
  }

  Duration _stod(String s) {
    if (s.isEmpty) {
      return const Duration(minutes: 0);
    }
    List<String> parts = s.split(':');
    return Duration(hours: int.parse(parts[0]), minutes: int.parse(parts[1]));
  }

  String _dtos(Duration d) {
    if (d == const Duration(minutes: 0)) {
      return '0:00';
    }
    final minutes = '${d.inMinutes.remainder(60)}';
    final hours = '${d.inHours}';
    return '$hours:${minutes.padLeft(2, '0')}';
  }

  FlightRecord _addTotals(FlightRecord totals, FlightRecord fr) {
    totals.timeSE = _dtos(_stod(totals.timeSE) + _stod(fr.timeSE));
    totals.timeME = _dtos(_stod(totals.timeME) + _stod(fr.timeME));
    totals.timeMCC = _dtos(_stod(totals.timeMCC) + _stod(fr.timeMCC));
    totals.timeTT = _dtos(_stod(totals.timeTT) + _stod(fr.timeTT));
    totals.timeNight = _dtos(_stod(totals.timeNight) + _stod(fr.timeNight));
    totals.timeIFR = _dtos(_stod(totals.timeIFR) + _stod(fr.timeIFR));
    totals.timePIC = _dtos(_stod(totals.timePIC) + _stod(fr.timePIC));
    totals.timeCOP = _dtos(_stod(totals.timeCOP) + _stod(fr.timeCOP));
    totals.timeDual = _dtos(_stod(totals.timeDual) + _stod(fr.timeDual));
    totals.timeInstr = _dtos(_stod(totals.timeInstr) + _stod(fr.timeInstr));
    totals.simTime = _dtos(_stod(totals.simTime) + _stod(fr.simTime));

    totals.dayLandings += fr.dayLandings;
    totals.nightLandings += fr.nightLandings;

    return totals;
  }
}
