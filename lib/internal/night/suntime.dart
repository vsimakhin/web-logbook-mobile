/// This package was forked from https://github.com/diego-garro/suntime-dart

import 'dart:math' as math;
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdl;

class SunTimeException implements Exception {
  String message;

  SunTimeException([this.message = 'invalid value']);

  @override
  String toString() {
    return message;
  }
}

/// Approximated calculation of the sunrise and sunset datetimes for
/// a given coordinates.
///
/// @param lat: the latitude as a double.
/// @param lon: the longitude as a double.
class Sun {
  final double lat;
  final double lon;

  Sun(this.lat, this.lon) {
    tzdl.initializeTimeZones();
  }

  /// Calculate the sunrise UTC time for a given date.
  ///
  /// @param date: Reference date. Today if not provided.
  ///
  /// Returns the `DateTime` sunrise date.
  ///
  /// Throws `SunTimeException` where there is no sunrise on the
  /// given location and date.
  DateTime getSunriseTime({DateTime? date}) {
    date ??= DateTime.now();
    final sunrise = _calcSunTime(date);
    if (sunrise == null) {
      throw SunTimeException('The sun never rises on this location (on the specified date)');
    }
    return sunrise;
  }

  /// Calculate the sunrise time for local or custom time zone for a given date.
  ///
  /// @param timeZone: Local or custom timezone (e.g. 'America/Detroit').
  /// @param date: Reference date. Today if not provided.
  ///
  /// Returns the `DateTime` sunrise date.
  ///
  /// Throws `SunTimeException` where there is no sunrise on the
  /// given location and date.
  DateTime getLocalSunriseTime(String timeZone, {DateTime? date}) {
    final sunrise = getSunriseTime(date: date);
    final tzone = tz.getLocation(timeZone);
    final zoneDateTime = tz.TZDateTime.from(sunrise, tzone);

    return zoneDateTime;
  }

  /// Calculate the sunset UTC time for a given date.
  ///
  /// @param date: Reference date. Today if not provided.
  ///
  /// Returns the `DateTime` sunset date.
  ///
  /// Throws `SunTimeException` where there is no sunset on the
  /// given location and date.
  DateTime getSunsetTime({DateTime? date}) {
    date ??= DateTime.now();
    final sunset = _calcSunTime(date, isRiseTime: false);
    if (sunset == null) {
      throw SunTimeException('The sun never sets on this location (on the specified date)');
    }
    return sunset;
  }

  /// Calculate the sunset time for local or custom time zone for a given date.
  ///
  /// @param timeZone: Local or custom timezone (e.g. 'America/Detroit').
  /// @param date: Reference date. Today if not provided.
  ///
  /// Returns the `DateTime` sunrise date.
  ///
  /// Throws `SunTimeException` where there is no sunrise on the
  /// given location and date.
  DateTime getLocalSunsetTime(String timeZone, {DateTime? date}) {
    final sunrise = getSunsetTime(date: date);
    final tzone = tz.getLocation(timeZone);
    final zoneDateTime = tz.TZDateTime.from(sunrise, tzone);

    return zoneDateTime;
  }

  /// Calculates sunrise or sunset date in UTC.
  ///
  /// Throws SunTimeException when there is no sunrise or sunset on given
  /// location and date.
  ///
  /// if `local` is set to true, returns local DateTime.
  DateTime? _calcSunTime(DateTime date, {bool isRiseTime = true, double zenith = 90.8}) {
    // isRiseTime == false, returns sunsetTime
    var day = date.day;
    var month = date.month;
    var year = date.year;

    const toRad = math.pi / 180.0;

    // 1. First step: Calculate the day of the year.
    final n1 = (275 * month / 9).floor();
    final n2 = ((month + 9) / 12).floor();
    final n3 = (1 + ((year - 4 * (year / 4).floor() + 2) / 3).floor());
    final n = n1 - (n2 * n3) + day - 30;

    // 2. Second step: Convert the longitude to hour and calculate an
    // approximate time.
    final lngHour = lon / 15;

    late double t;
    if (isRiseTime) {
      t = n + ((6 - lngHour) / 24);
    } else {
      t = n + ((18 - lngHour) / 24);
    }

    // 3. Third step: Calculate the Sun's mean anomaly.
    final m = (0.9856 * t) - 3.289;

    // 4. Fourth step: Calculate the Sun's true longitud.
    var l = m + (1.916 * math.sin(toRad * m)) + (0.020 * math.sin(toRad * 2 * m)) + 282.634;
    l = _forceRange(l, 360); // Note: l adjusted into the range [0, 360).

    // 5a. Fifth.a step: Calculate the Sun's right ascension.
    var ra = (1 / toRad) * math.atan(0.91764 * math.tan(toRad * l));
    ra = _forceRange(ra, 360); // Note: ra adjusted into the range [0, 360).

    // 5b. Fifth.b step: Right ascension value needs to be in the same quadrant
    // as l.
    final lQuadrant = (l / 90).floor() * 90;
    final raQuadrant = (ra / 90).floor() * 90;
    ra = ra + (lQuadrant - raQuadrant);

    // 5c. Fifth.c step: Right ascension value needs to be converted into hours.
    ra = ra / 15;

    // 6. Sixth step: Calculate the Sun's declination.
    final sinDec = 0.39782 * math.sin(toRad * l);
    final cosDec = math.cos(math.asin(sinDec));

    // 7.a Seventh.a step: Calculate the Sun's local hour angle.
    final cosH = (math.cos(toRad * zenith) - (sinDec * math.sin(toRad * lat))) / (cosDec * math.cos(toRad * lat));

    if (cosH > 1) {
      return null; // The sun never rises on this location (on the specified date).
    }
    if (cosH < -1) {
      return null; // The sun never sets on this location(on the specified date).
    }

    // 7.b Seventh.b step: Finish calculating h and convert it into hours.
    late final double h;
    if (isRiseTime) {
      h = (360 - (1 / toRad) * math.acos(cosH)) / 15.0;
    } else {
      h = ((1 / toRad) * math.acos(cosH)) / 15.0;
    }

    // 8. Eighth step: Calculate local mean time of rising/setting.
    final T = h + ra - (0.06571 * t) - 6.622;

    // 9. Nineth step: Adjust back to UTC.
    var ut = T - lngHour;
    ut = _forceRange(ut, 24); // UTC time in decimal format (e.g. 23.23)

    // 10. Tenth step: Return.
    var hr = _forceRange(ut, 24);
    var min = ((ut - ut.toInt()) * 60).roundToDouble();
    if (min == 60.0) {
      hr += 1;
      min = 0;
    }

    // Check corner case https://github.com/SatAgro/suntime/issues/1
    if (hr == 24) {
      hr = 0;
      day += 1;

      int lastday = DateTime(date.year, date.month + 1, 0).day;
      if (day > lastday) {
        day = 1;
        month += 1;

        if (month > 12) {
          month = 1;
          year += 1;
        }
      }
    }

    return DateTime.utc(year, month, day, hr.toInt(), min.toInt());
  }

  /// Forces a double to be >= 0 and < max.
  double _forceRange(double v, double max) {
    if (v < 0.0) {
      return v + max;
    } else if (v >= max) {
      return v - max;
    } else {
      return v;
    }
  }
}
