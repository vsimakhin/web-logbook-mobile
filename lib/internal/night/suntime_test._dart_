import 'package:test/test.dart';
import 'package:web_logbook_mobile/internal/night/suntime.dart';

void main() {
  final today = DateTime(2022, 6, 6);
  final tomorrow = today.add(const Duration(days: 1));

  group('Testing the Sun methods to get sunrise and sunset:', () {
    final sun = Sun(9.928069, -84.090725);
    test('Sunrise tests', () {
      expect(sun.getSunriseTime(date: tomorrow).toString(), '2022-06-07 11:15:00.000Z');
      expect(sun.getLocalSunriseTime('America/Costa_Rica', date: tomorrow).toString(), '2022-06-07 05:15:00.000-0600');
      expect(sun.getLocalSunriseTime('America/Halifax', date: tomorrow).toString(), '2022-06-07 08:15:00.000-0300');
    });

    test('Sunset tests', () {
      expect(sun.getSunsetTime(date: today).toString(), '2022-06-06 23:55:00.000Z');
      expect(sun.getLocalSunsetTime('America/Costa_Rica', date: today).toString(), '2022-06-06 17:55:00.000-0600');
      expect(sun.getLocalSunsetTime('America/Halifax', date: today).toString(), '2022-06-06 20:55:00.000-0300');
    });
  });

  group('Test sun never rises or sets on a given location:', () {
    final sun = Sun(85.0, 21.0);

    test('Sunrise', () {
      expect(() => sun.getSunriseTime(date: tomorrow), throwsA(isA<SunTimeException>()));
    });

    test('Sunset', () {
      expect(() => sun.getSunsetTime(date: today), throwsA(isA<SunTimeException>()));
    });
  });
}
