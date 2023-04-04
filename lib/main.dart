import 'models.dart';
import 'package:flutter/material.dart';
import 'flight.dart';
import 'flightrecords.dart';
import 'settings.dart';

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
      FlightPage(flightRecord: FlightRecord(isNew: true)),
      const SettingsPage(),
    ];
    _currentIndex = 0;
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web Logbook Mobile',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.connecting_airports),
              label: 'Flights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flight_takeoff),
              label: 'New Flight',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            )
          ],
        ),
      ),
    );
  }
}
