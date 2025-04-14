import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyWeatherAppHomePage extends StatefulWidget {
  const MyWeatherAppHomePage({super.key});

  @override
  State<MyWeatherAppHomePage> createState() => _MyWeatherAppHomePageState();
}

class _MyWeatherAppHomePageState extends State<MyWeatherAppHomePage> {
  double? _temp;
  String? _mainData;  
  List<dynamic>? forecastData;
  Map<String, dynamic>? currentWeather;
  
  Future<void> _getWeather() async {
    final Uri url = Uri.parse("https://api.openweathermap.org/data/2.5/forecast?q=Mumbai&appid=5e439e4d8a0e459801290f383c5b5511");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tempKelvin = data["list"][0]["main"]["temp"]; 
        final tempCelsius = tempKelvin - 273.15; 
        final weatherList = data["list"][0]["weather"] as List;
        final weatherData = weatherList[0]; 
        
        setState(() {
          _temp = tempCelsius;
          _mainData = weatherData["main"];
          forecastData = data["list"];
          currentWeather = data["list"][0];
        });
        
        debugPrint("Temperature: $tempCelsius°C, Weather: ${weatherData["main"]}");
      } else {
        debugPrint("Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error occurred: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _getWeather();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _getWeather,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${_temp?.toStringAsFixed(1) ?? '--'}°C", 
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      ),
                      const SizedBox(height: 20),
                      Icon(
                        _getWeatherIcon(_mainData),
                        size: 50,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _mainData ?? 'Loading...', 
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Text(
                        "Weather Forecast",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: forecastData == null
                          ? const Center(child: CircularProgressIndicator())
                          : ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (int i = 1; i <= 30; i++)
                                  _buildHourlyCard(
                                    forecastData![i]["dt_txt"].split(" ")[1].substring(0, 5),
                                    _getWeatherIcon(forecastData![i]["weather"][0]["main"]),
                                    "${(forecastData![i]["main"]["temp"] - 273.15).toStringAsFixed(1)}°C",
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Additional Information", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 20
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _additionalInfoCard(
                    Icons.water_drop, 
                    "Humidity", 
                    currentWeather?["main"]["humidity"]?.toString() ?? "--"
                  ),
                  _additionalInfoCard(
                    Icons.wind_power, 
                    "Wind Speed", 
                    currentWeather?["wind"]["speed"]?.toString() ?? "--"
                  ),
                  _additionalInfoCard(
                    Icons.umbrella, 
                    "Pressure", 
                    currentWeather?["main"]["pressure"]?.toString() ?? "--"
                  ),
                ],
              ),
            ),
          ],
        ), 
      ),
    );
  }

  IconData _getWeatherIcon(String? weatherCondition) {
    switch (weatherCondition?.toLowerCase()) {
      case "clear":
        return Icons.wb_sunny;
      case "clouds":
        return Icons.cloud;
      case "rain":
        return Icons.grain;
      case "thunderstorm":
        return Icons.flash_on;
      case "snow":
        return Icons.ac_unit;
      case "mist":
      case "smoke":
      case "haze":
      case "fog":
        return Icons.cloud_queue;
      default:
        return Icons.cloud;
    }
  }
}

Widget _buildHourlyCard(String time, IconData icon, String temp) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        height: 80,
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(time),
            Icon(icon),
            Text(temp),
          ],
        ),
      ),
    ),
  );
}

Widget _additionalInfoCard(IconData icon, String content, String value) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        Text(content),
        Text(value),
      ],
    ),
  );
}