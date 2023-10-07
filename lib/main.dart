import 'package:flutter/material.dart';
import 'package:web_logbook_mobile/models/models.dart';
import 'package:web_logbook_mobile/pages/flight/flight.dart';
import 'package:web_logbook_mobile/pages/flightrecords/flightrecords.dart';
import 'package:web_logbook_mobile/pages/settings/settings.dart';
import 'package:web_logbook_mobile/pages/stats/stats.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<Widget> _children;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _children = [
      const FlightRecordsPage(),
      const StatsPage(),
      const SettingsPage(),
    ];
    _currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web Logbook Mobile',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: _onTabTapped,
          currentIndex: _currentIndex,
          useLegacyColorScheme: false,
          selectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              label: 'Flights',
              icon: Icon(Icons.connecting_airports, color: Colors.grey),
            ),
            BottomNavigationBarItem(
              label: 'Stats',
              icon: Icon(Icons.bar_chart, color: Colors.grey),
            ),
            BottomNavigationBarItem(
              label: 'Settings & Sync',
              icon: Icon(Icons.settings, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
