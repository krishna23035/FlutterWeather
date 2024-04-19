import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isAutomaticMode = false;
  ThemeMode _selectedThemeMode = ThemeMode.light;
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
    if (_isAutomaticMode) {
      _updateThemeBasedOnTime();
    }
  }

  void _setAutomaticMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('automaticMode', value);
    setState(() {
      _isAutomaticMode = value;
    });
    if (value) {
      _updateThemeBasedOnTime();
    }
  }

  void _updateThemeBasedOnTime() {
    DateTime now = DateTime.now();
    if (now.hour >= 6 && now.hour < 18) {
      _setThemeMode(ThemeMode.light);
    } else {
      _setThemeMode(ThemeMode.dark);
    }
  }

  void _setThemeMode(ThemeMode themeMode) {
    setState(() {
      _selectedThemeMode = themeMode;
    });
    // Apply theme changes globally
    MyApp.setTheme(themeMode);
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
              color: Colors.transparent, // Make the container transparent
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Automatic Mode',
                    style: TextStyle(fontSize: 20, color: Colors.white), // Change text color to white
                  ),
                  Switch(
                    value: _isAutomaticMode,
                    onChanged: _setAutomaticMode,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Select Theme',
                    style: TextStyle(fontSize: 20, color: Colors.white), // Change text color to white
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _setThemeMode(ThemeMode.light);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // Change button background color to white
                    ),
                    child: Text('Light Theme', style: TextStyle(color: Colors.black)), // Change text color to black
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _setThemeMode(ThemeMode.dark);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // Change button background color to white
                    ),
                    child: Text('Dark Theme', style: TextStyle(color: Colors.black)), // Change text color to black
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Refresh Interval',
                    style: TextStyle(fontSize: 20, color: Colors.white), // Change text color to white
                  ),
                  DropdownButton<String>(
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
                        child: Text(value, style: TextStyle(color: Colors.black)), // Change text color to black
                      );
                    }).toList(),
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

class MyApp extends StatelessWidget {
  static ThemeData lightTheme = ThemeData.light();
  static ThemeData darkTheme = ThemeData.dark();

  static void setTheme(ThemeMode themeMode) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('themeMode', themeMode.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _getSavedThemeMode(),
      home: Scaffold(
        body: Center(
          child: Text('MyApp'),
        ),
      ),
    );
  }

  ThemeMode _getSavedThemeMode() {
    SharedPreferences.getInstance().then((prefs) {
      String? themeModeString = prefs.getString('themeMode');
      if (themeModeString != null) {
        return ThemeMode.values.firstWhere(
            (e) => e.toString() == themeModeString,
            orElse: () => ThemeMode.system);
      } else {
        return ThemeMode.system;
      }
    });
    return ThemeMode.system;
  }
}

void main() {
  runApp(MyApp());
}
