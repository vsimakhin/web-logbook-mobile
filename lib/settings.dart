import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'db.dart';
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
                child: const Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text('Syncing in progress...'),
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
                  if (value[0]) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data synced'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    final errorMessage = value[1];

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Some error occured during sync: $errorMessage'),
                        duration: const Duration(seconds: 3),
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

  Future<List<dynamic>> _sync() async {
    final httpClient = HttpClient();
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    final serverAddress = _serverAddressController.text.trim();

    dynamic jsonData;
    String sessionValue = '';

    if (_useAuthentication) {
      final loginUrl = Uri.parse('$serverAddress/login');
      final loginPayload = jsonEncode({
        'login': _usernameController.text,
        'password': _passwordController.text
      });

      final req = await httpClient.postUrl(loginUrl);
      req.headers.contentType = ContentType.json;
      req.followRedirects = false;
      req.write(loginPayload);
      final res = await req.close();
      final sessionCookie = res.headers['set-cookie'];
      sessionValue = sessionCookie![0].split(';')[0].split('=')[1];
    }

    // get deleted items
    try {
      final req =
          await httpClient.getUrl(Uri.parse('$serverAddress/sync/deleted'));
      if (_useAuthentication) {
        req.cookies.add(Cookie('session', sessionValue));
      }
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode == 200) {
        jsonData = jsonDecode(body);

        for (var i = 0; i < jsonData.length; i++) {
          await DBProvider.db
              .syncDeletedItems(DeletedItem.fromJson(jsonData[i]));
        }
      } else {
        return [false, 'response code ${res.statusCode}'];
      }
    } catch (e) {
      return [false, e];
    }

    // upload records to the main app
    List<FlightRecord> listFlightRecords = [];
    final rawFlightRecord = await DBProvider.db.getAllFlightRecords();
    for (var i = 0; i < rawFlightRecord.length; i++) {
      listFlightRecords.add(FlightRecord.fromData(rawFlightRecord[i]));
    }

    List<DeletedItem> listDeletedItems = [];
    final rawDeletedItems = await DBProvider.db.getDeletedItems();
    for (var i = 0; i < rawDeletedItems.length; i++) {
      listDeletedItems.add(DeletedItem.fromJson(rawDeletedItems[i]));
    }

    try {
      final jsonPayload = {
        'flight_records': listFlightRecords,
        'deleted_items': listDeletedItems
      };

      final req =
          await httpClient.postUrl(Uri.parse('$serverAddress/sync/upload'));
      if (_useAuthentication) {
        req.cookies.add(Cookie('session', sessionValue));
      }
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(jsonPayload));
      final res = await req.close();

      if (res.statusCode != 200) {
        return [false, 'response code ${res.statusCode}'];
      }
    } catch (e) {
      return [false, e];
    }

    // connect and get the recordsets to sync
    try {
      final req =
          await httpClient.getUrl(Uri.parse('$serverAddress/sync/data'));
      if (_useAuthentication) {
        req.cookies.add(Cookie('session', sessionValue));
      }

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode == 200) {
        jsonData = jsonDecode(body);
        for (var i = 0; i < jsonData.length; i++) {
          await DBProvider.db
              .syncFlightRecord(FlightRecord.fromJson(jsonData[i]));
        }
      } else {
        return [false, 'response code ${res.statusCode}'];
      }
    } catch (e) {
      return [false, e];
    }

    httpClient.close();

    return [true, ''];
  }
}
