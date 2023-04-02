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
    );
  }
}
