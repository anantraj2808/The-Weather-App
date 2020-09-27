import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';

void main() => runApp(WeatherApp());

class WeatherApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WeatherAppState();
  }
}

class _WeatherAppState extends State<WeatherApp> {
  var temperature;
  var location = 'New Delhi';
  var woeid = 28743736;
  var weather = 'lightcloud';
  var weatherTemp = '';
  var abbreviation = '';
  var errorMessage = '';

  var searchApiUrl = 'https://www.metaweather.com/api/location/search/?query=';
  var locationApiUrl = 'https://www.metaweather.com/api/location/';

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  void fetchSearch(String input) async {
    try {
    var searchResult = await http.get(searchApiUrl + input);
    var result = json.decode(searchResult.body)[0];

    setState(() {
      location = result["title"];
      woeid = result["woeid"];
    });
    } catch (error){
      setState(() {
        errorMessage = 'Sorry, we don\'t have data for this location. Try another search';
      });
    }
  }

  void fetchLocation() async {
    var locationResult = await http.get(locationApiUrl + woeid.toString());
    var result = json.decode(locationResult.body);
    var consolidated_weather = result["consolidated_weather"];
    var data = consolidated_weather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weatherTemp = data["weather_state_name"];
      weather = data["weather_state_name"].replaceAll(" ", "").toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });
  }

  void onTextSubmitted(String input) async{
    await fetchSearch(input);
    await fetchLocation();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/$weather.png'), fit: BoxFit.cover)),
        child: temperature == null
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Center(
                          child: Image.network(
                            '/static/img/weather/png/' + abbreviation + '.png',
                            width: 100.0,
                          ),
                        ),
                        Center(
                          child: Text(
                            temperature.toString() + " °C",
                            style:
                                TextStyle(fontSize: 60.0, color: Colors.white),
                          ),
                        ),
                        Center(
                          child: Text(
                            location,
                            style:
                                TextStyle(fontSize: 40.0, color: Colors.white),
                          ),
                        ),
                        Center(
                          child: Text(
                            weatherTemp,
                            style:
                                TextStyle(fontSize: 40.0, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          width: 300.0,
                          child: TextField(
                            onSubmitted: (String input) {
                              onTextSubmitted(input);
                            },
                            style:
                                TextStyle(fontSize: 25.0, color: Colors.white),
                            decoration: InputDecoration(
                                hintText: "Search for a place...",
                                prefixIcon:
                                    Icon(Icons.search, color: Colors.white),
                                hintStyle: TextStyle(
                                    fontSize: 18.0, color: Colors.white)),
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.only(right: 32.0, left: 32.0),
                          child: Text(errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize:
                                  Platform.isAndroid ? 15.0 : 20.0)),
                        )
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
