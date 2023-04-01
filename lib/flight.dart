import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'db.dart';
import 'main.dart';

class FlightPage extends StatefulWidget {
  const FlightPage({Key? key, required this.flightRecord}) : super(key: key);

  final Map<String, dynamic> flightRecord;

  @override
  State<FlightPage> createState() => _FlightPageState();
}

class _FlightPageState extends State<FlightPage> {
  _FlightPageState();

  late Map<String, dynamic> flightRecord;

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

  bool isNewFlight = true;
  String pageHeader = 'New Flight';
  String uuid = '';

  @override
  void initState() {
    super.initState();
    flightRecord = widget.flightRecord;

    if (flightRecord['uuid'] != '') {
      isNewFlight = false;

      // existing flight record
      uuid = flightRecord['uuid'];
      _date.text = flightRecord['date'];
      _departurePlace.text = flightRecord['departure_place'];
      _departureTime.text = flightRecord['departure_time'];
      _arrivalPlace.text = flightRecord['arrival_place'];
      _arrivalTime.text = flightRecord['arrival_time'];
      _aircraftModel.text = flightRecord['aircraft_model'];
      _aircraftReg.text = flightRecord['reg_name'];
      _timeSE.text = flightRecord['se_time'];
      _timeME.text = flightRecord['me_time'];
      _timeMCC.text = flightRecord['mcc_time'];
      _timeTT.text = flightRecord['total_time'];
      _dayLandings.text = flightRecord['day_landings'].toString();
      _nightLandings.text = flightRecord['night_landings'].toString();
      _timeNight.text = flightRecord['night_time'];
      _timeIFR.text = flightRecord['ifr_time'];
      _timePIC.text = flightRecord['pic_time'];
      _timeCOP.text = flightRecord['co_pilot_time'];
      _timeDual.text = flightRecord['dual_time'];
      _timeInstr.text = flightRecord['instructor_time'];
      _simType.text = flightRecord['sim_type'];
      _simTime.text = flightRecord['sim_time'];
      _picName.text = flightRecord['pic_name'];
      _remarks.text = flightRecord['remarks'];

      pageHeader =
          "Flight ${flightRecord['departure_place']} - ${flightRecord['arrival_place']}";
    } else {
      isNewFlight = true;
      // new flight record

      _date.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
  }

  void _saveFlight() {
    if (isNewFlight) {
      uuid = const Uuid().v4();
    }

    DBProvider.db.saveFlightRecord(
      {
        'uuid': uuid,
        'date': _date.text,
        'departure_place': _departurePlace.text,
        'departure_time': _departureTime.text,
        'arrival_place': _arrivalPlace.text,
        'arrival_time': _arrivalTime.text,
        'aircraft_model': _aircraftModel.text,
        'reg_name': _aircraftReg.text,
        'se_time': _timeSE.text,
        'me_time': _timeME.text,
        'mcc_time': _timeMCC.text,
        'total_time': _timeTT.text,
        'day_landings': _dayLandings.text,
        'night_landings': _nightLandings.text,
        'night_time': _timeNight.text,
        'ifr_time': _timeIFR.text,
        'pic_time': _timePIC.text,
        'co_pilot_time': _timeCOP.text,
        'dual_time': _timeDual.text,
        'instructor_time': _timeInstr.text,
        'sim_type': _simType.text,
        'sim_time': _simTime.text,
        'pic_name': _picName.text,
        'remarks': _remarks.text,
      },
      isNewFlight,
    );

    if (isNewFlight) {
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _date,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          icon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a date';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1980),
                              lastDate: DateTime(2101));

                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('dd/MM/yyyy').format(pickedDate);

                            setState(() {
                              _date.text = formattedDate;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _picName,
                        decoration: InputDecoration(
                          labelText: 'Pilot In Command',
                          icon: GestureDetector(
                            child: const Icon(Icons.person),
                            onDoubleTap: () {
                              _picName.text = 'Self';
                            },
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.characters,
                        controller: _departurePlace,
                        decoration: const InputDecoration(
                          labelText: 'Departure Place',
                          icon: Icon(Icons.flight_takeoff_outlined),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _departureTime,
                        decoration: const InputDecoration(
                          labelText: 'Departure Time',
                          icon: Icon(Icons.watch),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(4)
                        ],
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.characters,
                        controller: _arrivalPlace,
                        decoration: const InputDecoration(
                          labelText: 'Arrival Place',
                          icon: Icon(Icons.flight_land_outlined),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _arrivalTime,
                        decoration: const InputDecoration(
                          labelText: 'Arrival Time',
                          icon: Icon(Icons.watch),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(4)
                        ],
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _aircraftModel,
                        decoration: const InputDecoration(
                          labelText: 'Aircraft Model',
                          icon: Icon(Icons.flight),
                        ),
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _aircraftReg,
                        decoration: const InputDecoration(
                          labelText: 'Registration',
                          icon: Icon(Icons.tag),
                        ),
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _TimeField(
                        textController: _timeTT,
                        timeTT: _timeTT,
                        fieldLabel: 'Total',
                      ),
                    ),
                    Expanded(
                      child: _TimeField(
                        textController: _timeSE,
                        timeTT: _timeTT,
                        fieldLabel: 'SE',
                      ),
                    ),
                    Expanded(
                      child: _TimeField(
                        textController: _timeME,
                        timeTT: _timeTT,
                        fieldLabel: 'ME',
                      ),
                    ),
                    Expanded(
                      child: _TimeField(
                        textController: _timeMCC,
                        timeTT: _timeTT,
                        fieldLabel: 'MCC',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _TimeField(
                        textController: _timeNight,
                        timeTT: _timeTT,
                        fieldLabel: 'Night',
                      ),
                    ),
                    Expanded(
                      child: _TimeField(
                        textController: _timeIFR,
                        timeTT: _timeTT,
                        fieldLabel: 'IFR',
                      ),
                    ),
                    Expanded(
                      child: _TimeField(
                        textController: _timePIC,
                        timeTT: _timeTT,
                        fieldLabel: 'PIC',
                      ),
                    ),
                    Expanded(
                      child: _TimeField(
                        textController: _timeCOP,
                        timeTT: _timeTT,
                        fieldLabel: 'SIC',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _TimeField(
                        textController: _timeDual,
                        timeTT: _timeTT,
                        fieldLabel: 'Dual',
                      ),
                    ),
                    Expanded(
                      child: _TimeField(
                        textController: _timeInstr,
                        timeTT: _timeTT,
                        fieldLabel: 'Instr',
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _dayLandings,
                        decoration: const InputDecoration(
                          labelText: 'Day',
                          icon: Icon(Icons.sunny),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _nightLandings,
                        decoration: const InputDecoration(
                          labelText: 'Night',
                          icon: Icon(Icons.nightlight),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                    )
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
                    Expanded(
                      child: _TimeField(
                        textController: _simTime,
                        timeTT: _timeTT,
                        fieldLabel: 'Sim Time',
                      ),
                    )
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveFlight();

                            late String infoMsg;
                            if (isNewFlight) {
                              infoMsg = 'Flight record has been added';
                            } else {
                              infoMsg = 'Flight record has been updated';
                              Navigator.pop(context, true);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(infoMsg),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        child: const Text('Save'),
                      ),
                      const Spacer(),
                      Visibility(
                        visible: !isNewFlight,
                        child: _DeleteFlightRecordButton(
                          uuid: uuid,
                          flightRecordName:
                              '${_departurePlace.text} - ${_arrivalPlace.text}',
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.textController,
    required this.timeTT,
    required this.fieldLabel,
  });

  final TextEditingController textController;
  final TextEditingController timeTT;
  final String fieldLabel;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      decoration: InputDecoration(
        labelText: fieldLabel,
        icon: GestureDetector(
          child: const Icon(Icons.timer),
          onDoubleTap: () {
            textController.text = timeTT.text;
          },
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        LengthLimitingTextInputFormatter(5),
        _TimeFormatter(),
      ],
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
    );
  }
}

class _DeleteFlightRecordButton extends StatelessWidget {
  const _DeleteFlightRecordButton(
      {required this.uuid, required this.flightRecordName});

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
              onPressed: () {
                // delete
                DBProvider.db.deleteFlightRecord(uuid);

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MyApp()),
                  (route) => false,
                );
              },
              child: const Text('Yes, delete.'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No, keep it.'),
            ),
          ],
        ),
      ),
      child: const Text('Delete'),
    );
  }
}

class _TimeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String formattedText = newValue.text.replaceAll(':', '');

    // Only allow up to 5 characters
    if (formattedText.length > 4) {
      formattedText = formattedText.substring(0, 4);
    }

    if (formattedText.length == 4 &&
        int.parse(formattedText.substring(2)) > 59) {
      formattedText = formattedText.substring(0, 3);
    }

    if (formattedText.length > 3) {
      formattedText =
          '${formattedText.substring(0, 2)}:${formattedText.substring(2)}';
    } else if (formattedText.length > 2) {
      formattedText =
          '${formattedText.substring(0, 1)}:${formattedText.substring(1)}';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
