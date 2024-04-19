import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_weather/const.dart';
import 'package:flutter_weather/widget/currentLocationWeather.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:share_plus/share_plus.dart';
import '../widget/location.dart';
import '../widget/search.dart';

class HomePage extends StatefulWidget {
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;
  String _currentLocation = "Delhi";
  String _searchedLocation = "";
  final List<String> _extraLocations = CityData.cities;
  String? _selectedCity;
  ThemeMode _themeMode = ThemeMode.light;
  String _currentLocationWeather = "";

  @override
  void initState() {
    //change image and image pick ,done screen as 2nd screen,forn
    super.initState();

    _wf.currentWeatherByCityName(_currentLocation).then((w) {
      setState(() {
        _weather = w;
      });
    });
    _getWeatherData(_currentLocation);
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather App'),
          leading: PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'share') {
                _shareWeatherData();
              } else if (value == 'theme') {
                setState(() {
                  // Toggle between light and dark themes
                  _themeMode = _themeMode == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'share',
                child: Text('Share'),
              ),
              const PopupMenuItem<String>(
                value: 'theme',
                child: Text('Change Theme'),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () async {
                String? selectedCity = await showSearch<String>(
                  context: context,
                  delegate: CitySearchDelegate(_extraLocations),
                );
                if (selectedCity != null) {
                  setState(() {
                    _selectedCity = selectedCity;
                  });
                  _getWeatherData(selectedCity);
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            CurrentLocationWeatherWidget(
              location: _currentLocation,
              temperature: _currentLocationWeather,
            ),
            Expanded(
              child: _buildUI(),
            ),
            Container(
              height: 220,
              color: Colors.purple,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _extraLocations.length,
                itemBuilder: (context, index) {
                  return _buildLocationItem(_extraLocations[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(String location) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCity = location;
          if (_currentLocation == location && _selectedCity == null) {
            _getWeatherData(_currentLocation);
          } else {
            // Otherwise, show weather for the tapped location
            _getWeatherData(location);
          }

          //  print("$_currentLocation");
          // _currentLocation = location;
        });
        _getWeatherData(location);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              location,
              style: TextStyle(
                color: location == _selectedCity ? Colors.red : Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            if (_weather != null && _currentLocation == location)
              Column(
                children: [
                  Image.network(
                    "http://openweathermap.org/img/wn/${_weather?.weatherIcon}.png",
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              )
            else
              FutureBuilder<Weather?>(
                future: _wf.currentWeatherByCityName(location),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(
                      "Error fetching data",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return Column(
                      children: [
                        Image.network(
                          "http://openweathermap.org/img/wn/${snapshot.data?.weatherIcon}.png",
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          "${snapshot.data?.temperature?.celsius?.toStringAsFixed(0)}°C",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container(); // Placeholder for temperature
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    String currentLocation = placemarks[0].locality ?? "Unknown";
    Weather? weather = await _wf.currentWeatherByLocation(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _currentLocation = currentLocation; //add this
      _currentLocation = placemarks[0].locality ?? "Unknown";
    });
    _getWeatherData(_currentLocation);
  }

  void _getWeatherData(String location) {
    _wf.currentWeatherByCityName(location).then((w) {
      setState(() {
        _weather = w;
        //   _currentLocation = location;
        _searchedLocation = location;
      });
    });
  }

  Widget _buildUI() {
    if (_weather == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.0),
            _locationHeader(),
            SizedBox(height: 20.0),
            _dateTimeInfo(),
            SizedBox(height: 20.0),
            _temperatureInfo(),
            SizedBox(height: 20.0),
            _extraInfo(),
          ],
        ),
      );
    }
  }

  Widget _locationHeader() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 20.0),
          if (_selectedCity != null)
            _buildLocationItem(
                _selectedCity!), // Display only the selected city
        ],
      ),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          DateFormat("dd/MM/yyyy").format(now),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          DateFormat("EEEE").format(now),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _temperatureInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png",
              ),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Max Temperature: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}°C",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Min Temperature: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}°C",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              " ${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C",
              style: TextStyle(
                fontSize: 35,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _shareWeatherData() {
    if (_weather != null) {
      String temperature =
          "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C";
      String weatherData = "Current Temperature: $temperature";
      Share.share(weatherData);
    }
  }

  Widget _extraInfo() {
    return Column(
      children: [
        Text(
          "Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        // Text(
        //   "Precipitation: ${_weather?.precipitation?.toStringAsFixed(0)}%",
        //   style: TextStyle(
        //     fontSize: 18,
        //     color: Colors.white,
        //   ),
        // ),
      ],
    );
  }
}
