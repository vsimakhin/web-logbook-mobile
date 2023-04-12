import 'package:suntime/suntime.dart';
import 'dart:math';

// Place defines the departure/arrival point of a route
class Place {
  double lat;
  double lon;
  DateTime time;

  Place(this.lat, this.lon, this.time);

  DateTime sunrise() {
    final sun = Sun(lat, lon);
    return sun.getSunriseTime(date: time).add(const Duration(minutes: -30));
  }

  DateTime sunset() {
    final sun = Sun(lat, lon);
    return sun.getSunsetTime(date: time).add(const Duration(minutes: 30));
  }
}

// Just a route between two places
class Route {
  final Place departure;
  final Place arrival;

  Route(this.departure, this.arrival);

  double routeDistance() {
    return distance(departure, arrival);
  }

  Duration flightTime() {
    return arrival.time.difference(departure.time);
  }

  double flightSpeed() {
    return routeDistance() / (flightTime().inSeconds / 3600);
  }

  Place meetWithSun(String target) {
    const maxIterations = 20;
    const maxDiffSeconds = 30;

    int iter = 0;
    Duration diff = const Duration(seconds: 0);

    Place xPoint = midpoint(departure, arrival);
    Place startPoint;
    Place endPoint;

    double dist;
    double flightTime;

    startPoint = departure;
    endPoint = arrival;

    final speed = flightSpeed();

    while (iter < maxIterations) {
      iter++;

      xPoint = midpoint(startPoint, endPoint);

      dist = distance(departure, xPoint);
      flightTime = dist / speed * 60;

      xPoint.time = departure.time.add(Duration(minutes: flightTime.round()));

      if (target == "sunrise") {
        diff = xPoint.time.difference(xPoint.sunrise());
      } else {
        diff = xPoint.time.difference(xPoint.sunset());
      }

      if (diff.inSeconds.abs() > maxDiffSeconds) {
        if (diff.inSeconds > 0) {
          endPoint = xPoint;
        } else {
          startPoint = xPoint;
        }
      } else {
        break;
      }
    }

    return xPoint;
  }

  Duration nightTime() {
    Duration nightTime = const Duration(minutes: 0);

    DateTime rdsr = departure.sunrise();
    DateTime rdss = departure.sunset();
    DateTime rasr = arrival.sunrise();
    DateTime rass = arrival.sunset();

    if ((departure.time.isAfter(rdsr) && departure.time.isBefore(rdss)) &&
        (arrival.time.isAfter(rasr) && arrival.time.isBefore(rass))) {
      // full day flight
      nightTime = const Duration(minutes: 0);
    } else if (departure.time.isAfter(rdsr) && departure.time.isBefore(rdss)) {
      // flight from day to night, night landing
      final point = meetWithSun("sunset");
      nightTime = arrival.time.difference(point.time);
    } else if (arrival.time.isAfter(rasr) && arrival.time.isBefore(rass)) {
      // flight from night to day, day landing
      final point = meetWithSun("sunrise");
      nightTime = point.time.difference(departure.time);
    } else {
      // full night time
      nightTime = flightTime();
    }

    return nightTime;
  }
}

double deg2rad(double degrees) {
  return degrees * pi / 180;
}

double hsin(double theta) {
  return pow(sin(theta / 2), 2).toDouble();
}

// distance calculates the distance between two points
double distance(Place start, Place end) {
  final lat1 = deg2rad(start.lat);
  final lon1 = deg2rad(start.lon);
  final lat2 = deg2rad(end.lat);
  final lon2 = deg2rad(end.lon);

  const r = 6378100.0;
  final h = hsin(lat2 - lat1) + cos(lat1) * cos(lat2) * hsin(lon2 - lon1);

  return 2 * r * asin(sqrt(h)) / 1000 / 1.852; // nautical miles
}

// midpoint calculates the midpoint between two points
Place midpoint(Place start, Place end) {
  double lat;
  double lon;

  final lat1 = deg2rad(start.lat);
  final lon1 = deg2rad(start.lon);
  final lat2 = deg2rad(end.lat);
  final lon2 = deg2rad(end.lon);

  final dlon = lon2 - lon1;
  final bx = cos(lat2) * cos(dlon);
  final by = cos(lat2) * sin(dlon);
  lat = atan2(sin(lat1) + sin(lat2),
      sqrt((cos(lat1) + bx) * (cos(lat1) + bx) + by * by));
  lon = lon1 + atan2(by, (cos(lat1) + bx));

  lat = (lat * 180) / pi;
  lon = (lon * 180) / pi;

  final date = start.time.add(end.time.difference(start.time));
  return Place(lat, lon, date);
}
