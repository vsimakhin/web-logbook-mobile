import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'models.dart';

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
  bool _useAuthentication = false;
  bool _isSyncing = false;
  String _syncMessage = "";

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final serverAddress = await storage.read(key: 'serverAddress');
    final username = await storage.read(key: 'username');
    final password = await storage.read(key: 'password');
    final useAuthentication = await storage.read(key: 'useAuthentication');
    setState(() {
      _serverAddressController.text = serverAddress ?? '';
      _usernameController.text = username ?? '';
      _passwordController.text = password ?? '';
      _useAuthentication = useAuthentication == 'true';
    });
  }

  Future<void> _saveSettings() async {
    await storage.write(
        key: 'serverAddress', value: _serverAddressController.text);
    await storage.write(key: 'username', value: _usernameController.text);
    await storage.write(key: 'password', value: _passwordController.text);
    await storage.write(
        key: 'useAuthentication', value: _useAuthentication.toString());
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
              ),
              CheckboxListTile(
                secondary: const Icon(Icons.how_to_reg),
                contentPadding: EdgeInsets.zero,
                title: const Text('Use authentication'),
                value: _useAuthentication,
                onChanged: (value) {
                  setState(() {
                    _useAuthentication = value!;
                  });
                },
              ),
              if (_useAuthentication)
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
              const SizedBox(height: 40),
              Visibility(
                visible: _isSyncing,
                child: Row(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 20),
                    Text(_syncMessage),
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

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings saved'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_serverAddressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter server address'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                setState(() {
                  _isSyncing = true;
                });

                _sync().then((value) {
                  if (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data synced'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Some error occured during sync'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }

                  setState(() {
                    _isSyncing = false;
                  });
                });
              },
              child: const Text('Sync'),
            ),
          ],
        ),
      ],
    );
  }

  Future<bool> _sync() async {
    final serverAddress = _serverAddressController.text.trim();

    try {
      setState(() {
        _syncMessage = 'Connecting to $serverAddress...';
      });

      final response = await http.get(Uri.parse('$serverAddress/sync/data'));
      final jsonData = jsonDecode(response.body);

      setState(() {
        _syncMessage = 'Processing records...';
      });

      for (var i = 0; i < jsonData.length; i++) {
        print(jsonData[i]);
        print(FlightRecord.fromJson(jsonData[i]).uuid);
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
