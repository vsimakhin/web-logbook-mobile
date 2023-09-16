import 'dart:convert';

import 'package:flutter/services.dart';

class FlightRecord {
  FlightRecord({
    this.uuid = '',
    this.date = '',
    this.departurePlace = '',
    this.departureTime = '',
    this.arrivalPlace = '',
    this.arrivalTime = '',
    this.aircraftModel = '',
    this.aircraftReg = '',
    this.timeSE = '',
    this.timeME = '',
    this.timeMCC = '',
    this.timeTT = '',
    this.dayLandings = 0,
    this.nightLandings = 0,
    this.timeNight = '',
    this.timeIFR = '',
    this.timePIC = '',
    this.timeCOP = '',
    this.timeDual = '',
    this.timeInstr = '',
    this.simType = '',
    this.simTime = '',
    this.picName = '',
    this.remarks = '',
    this.updateTime = 0,
    this.isNew = false,
  });

  String uuid;
  String date;
  String departurePlace;
  String departureTime;
  String arrivalPlace;
  String arrivalTime;
  String aircraftModel;
  String aircraftReg;
  String timeSE;
  String timeME;
  String timeMCC;
  String timeTT;
  int dayLandings;
  int nightLandings;
  String timeNight;
  String timeIFR;
  String timePIC;
  String timeCOP;
  String timeDual;
  String timeInstr;
  String simType;
  String simTime;
  String picName;
  String remarks;
  int updateTime;

  bool isNew;

  factory FlightRecord.fromData(Map<String, dynamic> data) {
    return FlightRecord(
      uuid: data['uuid'] as String,
      date: data['date'] as String,
      departurePlace: data['departure_place'] as String,
      departureTime: data['departure_time'] as String,
      arrivalPlace: data['arrival_place'] as String,
      arrivalTime: data['arrival_time'] as String,
      aircraftModel: data['aircraft_model'] as String,
      aircraftReg: data['reg_name'] as String,
      timeSE: data['se_time'] as String,
      timeME: data['me_time'] as String,
      timeMCC: data['mcc_time'] as String,
      timeTT: data['total_time'] as String,
      dayLandings: data['day_landings'] as int,
      nightLandings: data['night_landings'] as int,
      timeNight: data['night_time'] as String,
      timeIFR: data['ifr_time'] as String,
      timePIC: data['pic_time'] as String,
      timeCOP: data['co_pilot_time'] as String,
      timeDual: data['dual_time'] as String,
      timeInstr: data['instructor_time'] as String,
      simType: data['sim_type'] as String,
      simTime: data['sim_time'] as String,
      picName: data['pic_name'] as String,
      remarks: data['remarks'] as String,
      updateTime: data['update_time'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'date': date,
      'departure': {
        'place': departurePlace,
        'time': departureTime,
      },
      'arrival': {
        'place': arrivalPlace,
        'time': arrivalTime,
      },
      'aircraft': {
        'model': aircraftModel,
        'reg_name': aircraftReg,
      },
      'time': {
        'se_time': timeSE,
        'me_time': timeME,
        'mcc_time': timeMCC,
        'total_time': timeTT,
        'ifr_time': timeIFR,
        'pic_time': timePIC,
        'co_pilot_time': timeCOP,
        'dual_time': timeDual,
        'instructor_time': timeInstr,
        'night_time': timeNight,
      },
      'landings': {
        'day': dayLandings,
        'night': nightLandings,
      },
      'sim': {
        'type': simType,
        'time': simTime,
      },
      'pic_name': picName,
      'remarks': remarks,
      'update_time': updateTime,
    };
  }
}

class DeletedItem {
  DeletedItem({
    required this.uuid,
    required this.tableName,
    required this.deleteTime,
  });

  String uuid;
  String tableName;
  String deleteTime;

  factory DeletedItem.fromData(Map<String, dynamic> data) {
    return DeletedItem(
      uuid: data['uuid'] as String,
      tableName: data['table_name'] as String,
      deleteTime: data['delete_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'table_name': tableName,
      'delete_time': deleteTime,
    };
  }
}

class Airport {
  Airport({
    required this.icao,
    required this.iata,
    required this.name,
    required this.city,
    required this.country,
    required this.elevation,
    required this.lat,
    required this.lon,
  });

  String icao;
  String iata;
  String name;
  String city;
  String country;
  int elevation;
  double lat;
  double lon;

  factory Airport.fromData(Map<String, dynamic> data) {
    return Airport(
      icao: data['icao'] as String,
      iata: data['iata'] as String,
      name: data['name'] as String,
      city: data['city'] as String,
      country: data['country'] as String,
      elevation: data['elevation'].toInt(),
      lat: data['lat'].toDouble(),
      lon: data['lon'].toDouble(),
    );
  }
}

class Connect {
  Connect({
    required this.url,
    required this.auth,
    required this.username,
    required this.password,
  });

  final String url;
  final bool auth;
  final String username;
  final String password;
}

class Attachment {
  Attachment({
    required this.uuid,
    required this.recordId,
    required this.documentName,
    required this.document,
  });

  String uuid;
  String recordId;
  String documentName;
  Uint8List document;

  factory Attachment.fromData(Map<String, dynamic> data) {
    return Attachment(
      uuid: data['uuid'] as String,
      recordId: data['record_id'] as String,
      documentName: data['document_name'] as String,
      document: const Base64Decoder().convert(data['document']),
    );
  }

  factory Attachment.fromMap(Map<String, dynamic> data) {
    return Attachment(
      uuid: data['uuid'] as String,
      recordId: data['record_id'] as String,
      documentName: data['document_name'] as String,
      document: data['document'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'record_id': recordId,
      'document_name': documentName,
      'document': document,
    };
  }
}
