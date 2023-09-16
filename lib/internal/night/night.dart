import 'dart:math';
import 'package:web_logbook_mobile/internal/night/suntime.dart';

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

  Future<Duration> nightTime() async {
    final speedPerMinute = flightSpeed() / 60;

    // assumed we split the route for 5 minutes segments (60 / 5)
    final maxDistanse = flightSpeed() / 12;

    return nightSegment(departure, arrival, maxDistanse, speedPerMinute);
  }
}

Duration nightSegment(
  Place start,
  Place end,
  double maxDistance,
  double speedPerMinute,
) {
  Duration d = const Duration(minutes: 0);

  final dist = distance(start, end);
  if (dist > maxDistance) {
    // too long, let's split it again
    Place mid = midpoint(start, end);
    // calculate time at the mid point
    // dist / 2 * 60000 / speedPerMinute
    final flightTime = dist * 30000 / speedPerMinute;
    mid.time = start.time.add(Duration(milliseconds: (flightTime).round()));

    d = nightSegment(start, mid, maxDistance, speedPerMinute) + nightSegment(mid, end, maxDistance, speedPerMinute);
  } else {
    // get sunrise and sunset for the end point
    // it could be calculated for the middle point again to be more precise,
    // but it will add few more calculations and the error is not so high
    final sr = end.sunrise();
    final ss = end.sunset();

    if (end.time.isAfter(sr) && end.time.isBefore(ss)) {
      d = const Duration(minutes: 0);
    } else {
      d = Duration(milliseconds: (dist / speedPerMinute * 60000).ceil());
    }
  }

  return d;
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
  lat = atan2(sin(lat1) + sin(lat2), sqrt((cos(lat1) + bx) * (cos(lat1) + bx) + by * by));
  lon = lon1 + atan2(by, (cos(lat1) + bx));

  lat = (lat * 180) / pi;
  lon = (lon * 180) / pi;

  final date = start.time.add(end.time.difference(start.time));
  return Place(lat, lon, date);
}
