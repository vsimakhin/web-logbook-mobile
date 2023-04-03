int getEpochTime() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

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

  factory FlightRecord.fromJson(Map<String, dynamic> data) {
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
      dayLandings: int.tryParse(data['day_landings'] as String) ?? 0,
      nightLandings: int.tryParse(data['night_landings'] as String) ?? 0,
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
      updateTime: int.tryParse(data['update_time'] as String) ?? getEpochTime(),
    );
  }

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
  int deleteTime;

  factory DeletedItem.fromJson(Map<String, dynamic> data) {
    return DeletedItem(
      uuid: data['uuid'] as String,
      tableName: data['table_name'] as String,
      deleteTime: int.tryParse(data['delete_time'] as String) ?? getEpochTime(),
    );
  }

  // factory DeletedItem.fromData(Map<String, dynamic> data) {
  //   return DeletedItem(
  //     uuid: data['uuid'] as String,
  //     tableName: data['table_name'] as String,
  //     deleteTime: data['delete_time'] as int,
  //   );
  // }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'table_name': tableName,
      'delete_time': deleteTime,
    };
  }
}
