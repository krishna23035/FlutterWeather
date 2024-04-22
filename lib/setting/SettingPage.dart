import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/scheduler.dart';
import 'package:flutter_weather/Services/local_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/local_notification.dart';
import '../Services/show_local_notification.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isAutomaticMode = false;
  String _selectedRefreshInterval = 'Every Hour';
  late NotificationService _notificationService;
  String? _currentTemperature;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkAndSetThemeBasedOnTime();
    _notificationService = NotificationService();
    _notificationService.initNotification();
    _getCurrentTemperature();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAutomaticMode = prefs.getBool('automaticMode') ?? false;
      _selectedRefreshInterval =
          prefs.getString('refreshInterval') ?? 'Every Hour';
    });
    if (_isAutomaticMode) {
      _setAutomaticMode(true);
    }
  }

  void _setAutomaticMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('automaticMode', value);
    setState(() {
      _isAutomaticMode = value;
    });
    if (value) {
      _setThemeBasedOnTime(); // Call _setThemeBasedOnTime when automatic mode is enabled
    }
  }

  void _setRefreshInterval(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('refreshInterval', value);
    setState(() {
      _selectedRefreshInterval = value;
    });
    // Implement logic to fetch weather data based on the selected refresh interval
  }

  void _setThemeBasedOnTime() {
    TimeOfDay currentTime = TimeOfDay.now();
    TimeOfDay morningTime = TimeOfDay(hour: 6, minute: 0);
    TimeOfDay eveningTime = TimeOfDay(hour: 18, minute: 0);

    if (_isAfter(currentTime, morningTime) &&
        _isBefore(currentTime, eveningTime)) {
      _setTheme(ThemeMode.light);
    } else {
      _setTheme(ThemeMode.dark);
    }
  }

  bool _isAfter(TimeOfDay time, TimeOfDay other) {
    if (time.hour > other.hour) {
      return true;
    } else if (time.hour == other.hour) {
      return time.minute > other.minute;
    } else {
      return false;
    }
  }

  bool _isBefore(TimeOfDay time, TimeOfDay other) {
    if (time.hour < other.hour) {
      return true;
    } else if (time.hour == other.hour) {
      return time.minute < other.minute;
    } else {
      return false;
    }
  }

  void _setTheme(ThemeMode themeMode) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('themeMode', themeMode.toString());
      setState(() {
        // Update the theme mode of the MaterialApp
        _themeMode = themeMode;
      });
    });
  }

  Future<void> _getCurrentTemperature() async {
    // Replace 'YOUR_API_KEY' with your actual API key from OpenWeatherMap
    final apiKey = '99b74b54a0590ea133bdd2d4a0598cbd';
    final cityName =
        'Delhi'; // Replace 'India' with your desired city name in India
    final url =
        'http://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    final body = json.decode(response.body);
    setState(() {
      _currentTemperature = body['main']['temp'].toString();
    });
  }

  void _checkAndSetThemeBasedOnTime() {
    if (_themeMode == ThemeMode.system) {
      final currentTime = DateTime.now().hour;
      if (currentTime >= 6 && currentTime < 18) {
        setState(() {
          _themeMode = ThemeMode.light;
        });
      } else {
        setState(() {
          _themeMode = ThemeMode.dark;
        });
      }
    }
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
                  SizedBox(height: 20),
                  // Text(
                  //   'Current Temperature: $_currentTemperature °C',
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     color: Colors.black,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.timer_outlined),
                    onPressed: () {
                      LocalNotifications.showScheduleNotification(
                          title: "Schedule Notification",
                          body: "This is a Schedule Notification",
                          payload: "This is schedule data");
                    }, //new added
                    label: Text("Schedule Notifications"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _getCurrentTemperature();
                      if (_currentTemperature != null) {
                        _notificationService.showNotification(
                          title: 'Current Weather ',
                          body: 'This is a notification body.',
                          temperature: _currentTemperature!,
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content:
                                  Text("Failed to fecth current temperature"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('ok'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Text('Show Notification'),
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp',
      themeMode: _themeMode,
      theme: ThemeData.light(),
      // Your light theme
      darkTheme: ThemeData.dark(),
      // Your dark theme
      home: SettingsPage(),
    );
  }
}

ThemeMode _themeMode = ThemeMode.light; // Default theme mode
