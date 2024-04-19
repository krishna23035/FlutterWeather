import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isAutomaticMode = false;
  String _selectedRefreshInterval = 'Every Hour';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAutomaticMode = prefs.getBool('automaticMode') ?? false;
      _selectedRefreshInterval =
          prefs.getString('refreshInterval') ?? 'Every Hour';
    });
  }

  void _setAutomaticMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('automaticMode', value);
    setState(() {
      _isAutomaticMode = value;
    });
  }

  void _setRefreshInterval(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('refreshInterval', value);
    setState(() {
      _selectedRefreshInterval = value;
    });
    // Implement logic to fetch weather data based on the selected refresh interval
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/Images.jpg', // Path to your image
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Automatic Mode',
                          style: TextStyle(
                            fontSize: 23,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Switch(
                          value: _isAutomaticMode,
                          onChanged: _setAutomaticMode,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Refresh Interval-',
                          style: TextStyle(
                            fontSize: 23,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        flex: 1,
                        child: DropdownButton<String>(
                          value: _selectedRefreshInterval,
                          onChanged: (String? value) {
                            if (value != null) {
                              _setRefreshInterval(value);
                            }
                          },
                          items: <String>['Every Hour', 'Every Day']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'MyApp',
    home: SettingsPage(),
  ));
}
