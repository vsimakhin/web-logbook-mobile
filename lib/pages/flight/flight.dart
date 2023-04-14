import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_airports.dart';
import 'package:web_logbook_mobile/driver/db_flightrecords.dart';

import 'package:web_logbook_mobile/models/models.dart';
import 'package:web_logbook_mobile/helpers/helpers.dart';
import 'package:web_logbook_mobile/internal/night/night.dart' as night;
import 'package:web_logbook_mobile/pages/flight/flight_landingfield.dart';

import 'package:web_logbook_mobile/pages/flight/flight_timefield.dart';
import 'package:web_logbook_mobile/pages/flight/flight_datefield.dart';
import 'package:web_logbook_mobile/pages/flight/flight_deletebutton.dart';
import 'package:web_logbook_mobile/pages/flight/flight_place.dart';
import 'package:web_logbook_mobile/pages/flight/flight_aircraft.dart';

class FlightPage extends StatefulWidget {
  const FlightPage({Key? key, required this.flightRecord}) : super(key: key);

  final FlightRecord flightRecord;

  @override
  State<FlightPage> createState() => _FlightPageState();
}

class _FlightPageState extends State<FlightPage> {
  _FlightPageState();

  late FlightRecord flightRecord;

  final _formKey = GlobalKey<FormState>();
  final _date = TextEditingController();
  final _departurePlace = TextEditingController();
  final _departureTime = TextEditingController();
  final _arrivalPlace = TextEditingController();
  final _arrivalTime = TextEditingController();
  final _dayLandings = TextEditingController();
  final _nightLandings = TextEditingController();
  final _aircraftModel = TextEditingController();
  final _aircraftReg = TextEditingController();
  final _picName = TextEditingController();
  final _timeTT = TextEditingController();
  final _timeSE = TextEditingController();
  final _timeME = TextEditingController();
  final _timeMCC = TextEditingController();
  final _timeNight = TextEditingController();
  final _timeIFR = TextEditingController();
  final _timePIC = TextEditingController();
  final _timeCOP = TextEditingController();
  final _timeDual = TextEditingController();
  final _timeInstr = TextEditingController();
  final _simType = TextEditingController();
  final _simTime = TextEditingController();
  final _remarks = TextEditingController();

  String pageHeader = 'New Flight';

  @override
  void dispose() {
    // dispose all text editing controllers
    _date.dispose();
    _departurePlace.dispose();
    _departureTime.dispose();
    _arrivalPlace.dispose();
    _arrivalTime.dispose();
    _dayLandings.dispose();
    _nightLandings.dispose();
    _aircraftModel.dispose();
    _aircraftReg.dispose();
    _picName.dispose();
    _timeTT.dispose();
    _timeSE.dispose();
    _timeME.dispose();
    _timeMCC.dispose();
    _timeNight.dispose();
    _timeIFR.dispose();
    _timePIC.dispose();
    _timeCOP.dispose();
    _timeDual.dispose();
    _timeInstr.dispose();
    _simType.dispose();
    _simTime.dispose();
    _remarks.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    flightRecord = widget.flightRecord;

    if (!flightRecord.isNew) {
      // existing flight record
      _date.text = flightRecord.date;
      _departurePlace.text = flightRecord.departurePlace;
      _departureTime.text = flightRecord.departureTime;
      _arrivalPlace.text = flightRecord.arrivalPlace;
      _arrivalTime.text = flightRecord.arrivalTime;
      _aircraftModel.text = flightRecord.aircraftModel;
      _aircraftReg.text = flightRecord.aircraftReg;
      _timeSE.text = flightRecord.timeSE;
      _timeME.text = flightRecord.timeME;
      _timeMCC.text = flightRecord.timeMCC;
      _timeTT.text = flightRecord.timeTT;
      _dayLandings.text = formatLandings(flightRecord.dayLandings);
      _nightLandings.text = formatLandings(flightRecord.dayLandings);
      _timeNight.text = flightRecord.timeNight;
      _timeIFR.text = flightRecord.timeIFR;
      _timePIC.text = flightRecord.timePIC;
      _timeCOP.text = flightRecord.timeCOP;
      _timeDual.text = flightRecord.timeDual;
      _timeInstr.text = flightRecord.timeInstr;
      _simType.text = flightRecord.simType;
      _simTime.text = flightRecord.simTime;
      _picName.text = flightRecord.picName;
      _remarks.text = flightRecord.remarks;

      pageHeader =
          "Flight ${flightRecord.departurePlace} - ${flightRecord.arrivalPlace}";
    } else {
      _date.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.flight_takeoff),
            const SizedBox(width: 10),
            Text(pageHeader),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DateField(ctrl: _date),
                    Expanded(
                      child: TextFormField(
                        controller: _picName,
                        decoration: InputDecoration(
                          labelText: 'Pilot In Command',
                          icon: GestureDetector(
                            child: const Icon(Icons.person),
                            onDoubleTap: () => _picName.text = 'Self',
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                FlightPlace(
                    ctrlPlace: _departurePlace,
                    ctrlTime: _departureTime,
                    name: 'Departure',
                    calculateTotalTime: _calculateTotalTime,
                    calculateNightTime: _calculateNightTime),
                FlightPlace(
                    ctrlPlace: _arrivalPlace,
                    ctrlTime: _arrivalTime,
                    name: 'Arrival',
                    calculateTotalTime: _calculateTotalTime,
                    calculateNightTime: _calculateNightTime),
                Aircraft(ctrlModel: _aircraftModel, ctrlReg: _aircraftReg),
                Row(
                  children: <Widget>[
                    TimeField(ctrl: _timeTT, tt: _timeTT, lbl: 'Total'),
                    TimeField(ctrl: _timeSE, tt: _timeTT, lbl: 'SE'),
                    TimeField(ctrl: _timeME, tt: _timeTT, lbl: 'ME'),
                    TimeField(ctrl: _timeMCC, tt: _timeTT, lbl: 'MCC'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    TimeField(ctrl: _timeNight, tt: _timeTT, lbl: 'Night'),
                    TimeField(ctrl: _timeIFR, tt: _timeTT, lbl: 'IFR'),
                    TimeField(ctrl: _timePIC, tt: _timeTT, lbl: 'PIC'),
                    TimeField(ctrl: _timeCOP, tt: _timeTT, lbl: 'SIC'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    TimeField(ctrl: _timeDual, tt: _timeTT, lbl: 'Dual'),
                    TimeField(ctrl: _timeInstr, tt: _timeTT, lbl: 'Instr'),
                    LandingField(ctrl: _dayLandings, name: 'Day'),
                    LandingField(ctrl: _nightLandings, name: 'Night'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _simType,
                        decoration: const InputDecoration(
                          labelText: 'Sim Type',
                          icon: Icon(Icons.flight),
                        ),
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 10),
                    TimeField(ctrl: _simTime, tt: _timeTT, lbl: 'Sim Time')
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _remarks,
                        decoration: const InputDecoration(
                          labelText: 'Remarks',
                          icon: Icon(Icons.notes),
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        Row(
          children: [
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _onSaveButtonPressed();
                }
              },
            ),
            const Spacer(),
            Visibility(
              visible: !flightRecord.isNew,
              child: DeleteFlightRecordButton(
                uuid: flightRecord.uuid,
                flightRecordName:
                    '${_departurePlace.text} - ${_arrivalPlace.text}',
              ),
            )
          ],
        ),
      ],
    );
  }

  // Runs when Save button pressed
  void _onSaveButtonPressed() {
    flightRecord.date = _date.text;
    flightRecord.departurePlace = _departurePlace.text;
    flightRecord.departureTime = _departureTime.text;
    flightRecord.arrivalPlace = _arrivalPlace.text;
    flightRecord.arrivalTime = _arrivalTime.text;
    flightRecord.aircraftModel = _aircraftModel.text;
    flightRecord.aircraftReg = _aircraftReg.text;
    flightRecord.timeSE = _timeSE.text;
    flightRecord.timeME = _timeME.text;
    flightRecord.timeMCC = _timeMCC.text;
    flightRecord.timeTT = _timeTT.text;
    flightRecord.dayLandings = int.tryParse(_dayLandings.text) ?? 0;
    flightRecord.nightLandings = int.tryParse(_nightLandings.text) ?? 0;
    flightRecord.timeNight = _timeNight.text;
    flightRecord.timeIFR = _timeIFR.text;
    flightRecord.timePIC = _timePIC.text;
    flightRecord.timeCOP = _timeCOP.text;
    flightRecord.timeDual = _timeDual.text;
    flightRecord.timeInstr = _timeInstr.text;
    flightRecord.simType = _simType.text;
    flightRecord.simTime = _simTime.text;
    flightRecord.picName = _picName.text;
    flightRecord.remarks = _remarks.text;

    // insert or update the flight record
    DBProvider.db.saveFlightRecord(flightRecord);

    late String info;
    if (flightRecord.isNew) {
      // in case the flight record was new, let's pretend there
      // will be another one, so we can change departure vs arrival
      // and keep the same aircraft
      setState(() {
        _departurePlace.text = _arrivalPlace.text;
        _departureTime.clear();
        _arrivalPlace.clear();
        _arrivalTime.clear();
        _dayLandings.clear();
        _nightLandings.clear();
        // _aircraftModel.clear();
        // _aircraftReg.clear();
        _picName.clear();

        _timeTT.clear();
        _timeSE.clear();
        _timeME.clear();
        _timeMCC.clear();
        _timeNight.clear();
        _timeIFR.clear();
        _timePIC.clear();
        _timeCOP.clear();
        _timeDual.clear();
        _timeInstr.clear();

        _simType.clear();
        _simTime.clear();

        _remarks.clear();
      });

      info = 'Flight record has been added';
    } else {
      info = 'Flight record has been updated';
      Navigator.pop(context, true);
    }

    showInfo(context, info);
  }

  /// The function calculates a total flight time
  void _calculateTotalTime() {
    final start = _departureTime.text;
    final end = _arrivalTime.text;

    if (start.length == 4 && end.length == 4) {
      int startHour = int.parse(start.substring(0, 2));
      int startMinute = int.parse(start.substring(2));
      int endHour = int.parse(end.substring(0, 2));
      int endMinute = int.parse(end.substring(2));

      int hourDiff = endHour - startHour;
      int minuteDiff = endMinute - startMinute;

      if (hourDiff < 0) {
        hourDiff += 24;
      }

      if (minuteDiff < 0) {
        minuteDiff += 60;
        hourDiff--;
      }

      String hourString = hourDiff.toString().padLeft(2, '0');
      String minuteString = minuteDiff.toString().padLeft(2, '0');

      _timeTT.text = '$hourString:$minuteString'.replaceFirst('0', '');
    }
  }

  void _calculateNightTime() async {
    List<Map<String, Object?>> res;
    late Airport departureAirport;
    late Airport arrivalAirport;
    late DateTime departureTime;
    late DateTime arrivalTime;

    if (_departurePlace.text != '' &&
        _arrivalPlace.text != '' &&
        _departureTime.text.length == 4 &&
        _arrivalTime.text.length == 4) {
      // get airports from the database
      res = await DBProvider.db.getAirport(_departurePlace.text);
      if (res.isNotEmpty) {
        departureAirport = Airport.fromData(res.first);
      } else {
        return;
      }

      res = await DBProvider.db.getAirport(_arrivalPlace.text);
      if (res.isNotEmpty) {
        arrivalAirport = Airport.fromData(res.first);
      } else {
        return;
      }

      // get departure and arrival times
      final date = DateFormat('dd/MM/yyyy').parse(_date.text);
      departureTime = DateTime.utc(
          date.year,
          date.month,
          date.day,
          int.parse(_departureTime.text.substring(0, 2)),
          int.parse(_departureTime.text.substring(2)));
      arrivalTime = DateTime.utc(
          date.year,
          date.month,
          date.day,
          int.parse(_arrivalTime.text.substring(0, 2)),
          int.parse(_arrivalTime.text.substring(2)));

      if (arrivalTime.isBefore(departureTime)) {
        arrivalTime = arrivalTime.add(const Duration(days: 1));
      }

      // calculate night time
      final route = night.Route(
        night.Place(departureAirport.lat, departureAirport.lon, departureTime),
        night.Place(arrivalAirport.lat, arrivalAirport.lon, arrivalTime),
      );
      final nightTime = route.nightTime();
      final hh = (nightTime.inHours).toString().padLeft(2, '0');
      final mm = (nightTime.inMinutes % 60).toString().padLeft(2, '0');
      //remove first 0 if it's there
      _timeNight.text = '$hh:$mm'.replaceFirst('0', '');
    }
  }
}
