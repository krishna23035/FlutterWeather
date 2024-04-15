import 'package:flutter/material.dart';
import 'package:flutter_weather/const.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;
  String _currentLocation = "Delhi";
  List<String> _extraLocations = [
    'New York',
    'Paris',
    'Tokyo',
    'Sydney',
    'London',
    'Los Angeles',
    'Berlin',
    'Beijing',
    'Moscow',
    'Rio de Janeiro',
    'Mumbai',
    'Rome',
    'Cairo',
    'Toronto',
    'Dubai',
    'Singapore',
  ];

  @override
  void initState() {
    super.initState();

    _wf.currentWeatherByCityName(_currentLocation).then((w) {
      setState(() {
        _weather = w;
      });
    });
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
    );
  }

  Widget _buildLocationItem(String location) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentLocation = location;
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
                color: location == _currentLocation ? Colors.red : Colors.white,
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
    setState(() {
      _currentLocation = placemarks[0].locality ?? "Unknown";
    });
    _getWeatherData(_currentLocation);
  }

  void _getWeatherData(String location) {
    _wf.currentWeatherByCityName(location).then((w) {
      setState(() {
        _weather = w;
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
    String locationName = _currentLocation;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 20.0),
          _buildLocationItem(_currentLocation),
          SizedBox(width: 20.0),
          for (String location in _extraLocations) _buildLocationItem(location),
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
