import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:web_logbook_mobile/helpers/model_theme.dart';
import 'package:web_logbook_mobile/pages/flightrecords/flightrecords.dart';
import 'package:web_logbook_mobile/pages/settings/settings.dart';
import 'package:web_logbook_mobile/pages/stats/stats.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<Widget> _children;
  late int _currentIndex;

  final storage = const FlutterSecureStorage();

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
    return ChangeNotifierProvider(
      create: (_) => ModelTheme(),
      child: Consumer<ModelTheme>(builder: (context, ModelTheme themeNotifier, child) {
        return MaterialApp(
          title: 'Web Logbook Mobile',
          themeMode: themeNotifier.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.grey,
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
      }),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
