import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:web_logbook_mobile/internal/sync/sync.dart';
import 'package:web_logbook_mobile/internal/sync/sync_flightrecords.dart';
import 'package:web_logbook_mobile/internal/sync/sync_airports.dart';

import 'package:web_logbook_mobile/helpers/helpers.dart';
import 'package:web_logbook_mobile/models/models.dart';
import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_airports.dart';
import 'package:web_logbook_mobile/driver/db_flightrecords.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _serverAddressController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  int _airports = 0;
  int _flightRecords = 0;
  bool _useAuth = false;
  bool _isSyncing = false;

  final storage = const FlutterSecureStorage();

  static const _serverAddressKey = "serverAddress";
  static const _usernameKey = "username";
  static const _passwordKey = "password";
  static const _useAuthKey = "useAuth";

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getAirportsCount();
    _getFlightRecordsCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [Icon(Icons.settings), SizedBox(width: 10), Text('Settings')],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // server address
              TextFormField(
                controller: _serverAddressController,
                decoration: const InputDecoration(labelText: 'Server address', icon: Icon(Icons.computer)),
                validator: (value) => _fieldValidator(value, "server address"),
              ),
              // either use authentication or not
              CheckboxListTile(
                secondary: const Icon(Icons.how_to_reg),
                contentPadding: EdgeInsets.zero,
                title: const Text('Use authentication'),
                value: _useAuth,
                onChanged: (value) {
                  setState(() => _useAuth = value!);
                },
              ),
              if (_useAuth)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Username', icon: Icon(Icons.person)),
                        validator: (value) => _fieldValidator(value, "username"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password', icon: Icon(Icons.password)),
                        validator: (value) => _fieldValidator(value, "password"),
                      ),
                    ),
                  ],
                ),
              const Divider(),
              // Flight records
              Row(
                children: [
                  const Icon(Icons.connecting_airports),
                  const SizedBox(width: 15),
                  Text('Flight records: $_flightRecords'),
                  const Spacer(),
                  ElevatedButton(
                    child: const Text('Update'),
                    onPressed: () {
                      if (_isSyncing) return;
                      _syncFlightRecords();
                    },
                  )
                ],
              ),
              // Airport DB
              Row(
                children: [
                  const Icon(Icons.local_airport),
                  const SizedBox(width: 15),
                  Text('Airports: $_airports'),
                  const Spacer(),
                  ElevatedButton(
                    child: const Text('Update'),
                    onPressed: () {
                      if (_isSyncing) return;
                      _dowloadAirports();
                    },
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 40),
              Visibility(
                visible: _isSyncing,
                child: const Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text('Synchronization is in progress...'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        Row(
          children: [
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveSettings();
                  showInfo(context, 'Settings saved');
                }
              },
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  // Load settings from the secure storage since we have there
  // login and password
  Future<void> _loadSettings() async {
    final serverAddress = await storage.read(key: _serverAddressKey);
    final username = await storage.read(key: _usernameKey);
    final password = await storage.read(key: _passwordKey);
    final useAuth = await storage.read(key: _useAuthKey);

    setState(() {
      _serverAddressController.text = serverAddress ?? '';
      _usernameController.text = username ?? '';
      _passwordController.text = password ?? '';
      _useAuth = useAuth == 'true';
    });
  }

  // Save settings
  Future<void> _saveSettings() async {
    await storage.write(key: _serverAddressKey, value: _serverAddressController.text);
    await storage.write(key: _usernameKey, value: _usernameController.text);
    await storage.write(key: _passwordKey, value: _passwordController.text);
    await storage.write(key: _useAuthKey, value: _useAuth.toString());

    setState(() {});
  }

  Connect get connect {
    return Connect(
      url: _serverAddressController.text,
      auth: _useAuth,
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _getAirportsCount() async {
    final count = await DBProvider.db.getAirportsCount();
    setState(() {
      _airports = count ?? 0;
    });
  }

  Future<void> _getFlightRecordsCount() async {
    final count = await DBProvider.db.getFlightRecordsCount();
    setState(() {
      _flightRecords = count ?? 0;
    });
  }

  Future<void> _dowloadAirports() async {
    setState(() => _isSyncing = true);

    final res = await Sync(connect: connect).downloadAirports();

    setState(() {
      _isSyncing = false;
    });
    _getAirportsCount();

    if (!mounted) return;

    if (res == null) {
      showInfo(context, 'Airport DB downloaded');
    } else {
      showError(context, 'Error downloading Airport DB: $res');
    }
  }

  Future<void> _syncFlightRecords() async {
    setState(() => _isSyncing = true);

    final res = await Sync(connect: connect).syncFlightRecords();

    setState(() {
      _isSyncing = false;
    });
    _getFlightRecordsCount();

    if (!mounted) return;

    if (res == null) {
      showInfo(context, 'Flight records updated');
    } else {
      showError(context, 'Error updating flight records: $res');
    }
  }

  // field validator
  String? _fieldValidator(String? value, String? msg) {
    if (value == null || value.isEmpty) {
      return 'Please enter $msg';
    }
    return null;
  }
}
