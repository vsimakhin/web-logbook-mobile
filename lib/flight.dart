import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'db.dart';
import 'main.dart';
import 'models.dart';

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
      if (flightRecord.dayLandings == 0) {
        _dayLandings.text = '';
      } else {
        _dayLandings.text = flightRecord.dayLandings.toString();
      }
      if (flightRecord.nightLandings == 0) {
        _nightLandings.text = '';
      } else {
        _nightLandings.text = flightRecord.nightLandings.toString();
      }
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

  void _saveFlight() {
    DBProvider.db.saveFlightRecord(flightRecord);

    if (flightRecord.isNew) {
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

      _timeTT.text = '$hourString:$minuteString';
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
                        onChanged: (value) {
                          _calculateTotalTime();
                        },
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
                        onChanged: (value) {
                          _calculateTotalTime();
                        },
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
              ],
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
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
                  flightRecord.dayLandings =
                      int.tryParse(_dayLandings.text) ?? 0;
                  flightRecord.nightLandings =
                      int.tryParse(_nightLandings.text) ?? 0;
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

                  _saveFlight();

                  late String infoMsg;
                  if (flightRecord.isNew) {
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
              visible: !flightRecord.isNew,
              child: _DeleteFlightRecordButton(
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
