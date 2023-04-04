import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'sync.dart';

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

  // Load settings from the secure storage since we have there
  // login and password
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

  // Save settings
  Future<void> _saveSettings() async {
    await storage.write(
        key: 'serverAddress', value: _serverAddressController.text);
    await storage.write(key: 'username', value: _usernameController.text);
    await storage.write(key: 'password', value: _passwordController.text);
    await storage.write(
        key: 'useAuthentication', value: _useAuthentication.toString());
  }

  Future<void> _onSyncButtonPressed() async {
    setState(() {
      _isSyncing = true;
    });

    Sync(
      serverAddress: _serverAddressController.text,
      useAuthentication: _useAuthentication,
      username: _usernameController.text,
      password: _passwordController.text,
    ).runSync().then((value) {
      if (value == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        final error = 'Some error occured during sync: $value';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      setState(() {
        _isSyncing = false;
      });
    });
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
}
