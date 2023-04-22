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
  const FlightPage({Key? key, required this.fr}) : super(key: key);

  final FlightRecord fr;

  @override
  State<FlightPage> createState() => _FlightPageState();
}

class _FlightPageState extends State<FlightPage> {
  _FlightPageState();

  late FlightRecord fr;

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
    fr = widget.fr;

    if (!fr.isNew) {
      // existing flight record
      _date.text = fr.date;
      _departurePlace.text = fr.departurePlace;
      _departureTime.text = fr.departureTime;
      _arrivalPlace.text = fr.arrivalPlace;
      _arrivalTime.text = fr.arrivalTime;
      _aircraftModel.text = fr.aircraftModel;
      _aircraftReg.text = fr.aircraftReg;
      _timeSE.text = fr.timeSE;
      _timeME.text = fr.timeME;
      _timeMCC.text = fr.timeMCC;
      _timeTT.text = fr.timeTT;
      _dayLandings.text = formatLandings(fr.dayLandings);
      _nightLandings.text = formatLandings(fr.dayLandings);
      _timeNight.text = fr.timeNight;
      _timeIFR.text = fr.timeIFR;
      _timePIC.text = fr.timePIC;
      _timeCOP.text = fr.timeCOP;
      _timeDual.text = fr.timeDual;
      _timeInstr.text = fr.timeInstr;
      _simType.text = fr.simType;
      _simTime.text = fr.simTime;
      _picName.text = fr.picName;
      _remarks.text = fr.remarks;

      if (fr.departurePlace != '' && fr.arrivalPlace != '') {
        pageHeader = "Flight ${fr.departurePlace} - ${fr.arrivalPlace}";
      } else if (fr.aircraftModel != '' && fr.aircraftReg != '') {
        pageHeader = "Flight ${fr.aircraftModel} ${fr.aircraftReg}";
      } else if (fr.simType != '') {
        pageHeader = "Flight record ${fr.simType}";
      } else {
        pageHeader = "Flight record";
      }
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
              visible: !fr.isNew,
              child: DeleteFlightRecordButton(
                uuid: fr.uuid,
                frName: '${_departurePlace.text} - ${_arrivalPlace.text}',
              ),
            )
          ],
        ),
      ],
    );
  }

  // Runs when Save button pressed
  void _onSaveButtonPressed() {
    fr.date = _date.text;
    fr.departurePlace = _departurePlace.text;
    fr.departureTime = _departureTime.text;
    fr.arrivalPlace = _arrivalPlace.text;
    fr.arrivalTime = _arrivalTime.text;
    fr.aircraftModel = _aircraftModel.text;
    fr.aircraftReg = _aircraftReg.text;
    fr.timeSE = _timeSE.text;
    fr.timeME = _timeME.text;
    fr.timeMCC = _timeMCC.text;
    fr.timeTT = _timeTT.text;
    fr.dayLandings = int.tryParse(_dayLandings.text) ?? 0;
    fr.nightLandings = int.tryParse(_nightLandings.text) ?? 0;
    fr.timeNight = _timeNight.text;
    fr.timeIFR = _timeIFR.text;
    fr.timePIC = _timePIC.text;
    fr.timeCOP = _timeCOP.text;
    fr.timeDual = _timeDual.text;
    fr.timeInstr = _timeInstr.text;
    fr.simType = _simType.text;
    fr.simTime = _simTime.text;
    fr.picName = _picName.text;
    fr.remarks = _remarks.text;

    // insert or update the flight record
    DBProvider.db.saveFlightRecord(fr);

    late String info;
    if (fr.isNew) {
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
  Future<void> _calculateTotalTime() async {
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

  Future<void> _calculateNightTime() async {
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

      final nightTime = await route.nightTime();

      if (nightTime.inMinutes != 0) {
        final hh = (nightTime.inHours).toString().padLeft(2, '0');
        final mm = (nightTime.inMinutes % 60).toString().padLeft(2, '0');

        //remove first 0 if it's there
        _timeNight.text = '$hh:$mm'.replaceFirst('0', '');
      } else {
        _timeNight.text = '';
      }
    }
  }
}
