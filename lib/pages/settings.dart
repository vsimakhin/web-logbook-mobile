import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:web_logbook_mobile/internal/sync/sync.dart';
import 'package:web_logbook_mobile/internal/sync/sync_flightrecords.dart';
import 'package:web_logbook_mobile/internal/sync/sync_airports.dart';
import 'package:web_logbook_mobile/helpers/helpers.dart';
import 'package:web_logbook_mobile/driver/db.dart';
import 'package:web_logbook_mobile/driver/db_airports.dart';
import 'package:web_logbook_mobile/models/models.dart';

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

  bool _useAuth = false;
  bool _isSyncing = false;
  int airports = 0;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.settings),
            SizedBox(width: 10),
            Text('Settings'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _serverAddressController,
                decoration: const InputDecoration(
                  labelText: 'Server address',
                  icon: Icon(
                    Icons.computer,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Server address';
                  }
                  return null;
                },
              ),
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
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          icon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          icon: Icon(Icons.password),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.local_airport),
                  const SizedBox(width: 15),
                  Text('Airports in database: $airports'),
                  const Spacer(),
                  ElevatedButton(
                    child: const Text('Update'),
                    onPressed: () {
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveSettings();
                  showInfo(context, 'Settings saved');
                }
              },
              child: const Text('Save'),
            ),
            const Spacer(),
            ElevatedButton(
              child: const Text('Sync'),
              onPressed: () {
                _onSyncButtonPressed();
              },
            ),
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
    await storage.write(
        key: _serverAddressKey, value: _serverAddressController.text);
    await storage.write(key: _usernameKey, value: _usernameController.text);
    await storage.write(key: _passwordKey, value: _passwordController.text);
    await storage.write(key: _useAuthKey, value: _useAuth.toString());
  }

  Connect get connect {
    return Connect(
      url: _serverAddressController.text,
      auth: _useAuth,
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _onSyncButtonPressed() async {
    setState(() => _isSyncing = true);

    final error = await Sync(connect: connect).runSync();

    if (!mounted) return;

    if (error == null) {
      showInfo(context, 'Data synchronized');
    } else {
      showInfo(context, 'Some error occured during sync: $error');
    }

    setState(() => _isSyncing = false);
  }

  Future<void> _getAirportsCount() async {
    final count = await DBProvider.db.getAirportsCount();
    airports = count ?? 0;
  }

  Future<void> _dowloadAirports() async {
    setState(() => _isSyncing = true);

    final res = await Sync(connect: connect).downloadAirports();

    setState(() {
      _isSyncing = false;
      _getAirportsCount();
    });

    if (!mounted) return;

    if (res == null) {
      showInfo(context, 'Airports downloaded');
    } else {
      showError(context, 'Error downloading airports: $res');
    }
  }
}
