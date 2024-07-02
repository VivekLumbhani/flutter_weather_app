import 'package:flutter/material.dart';
import 'package:weatherapp/api/api.dart';
import 'package:weatherapp/modals/weatherModal.dart';
import 'package:weatherapp/screens/detailscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiResponse? response;
  bool inProgress = false;
  TextEditingController _searchController = TextEditingController();
  List<String> _lastSearchedLocations = [];

  @override
  void initState() {
    super.initState();
    _loadLastSearchedLocations();
  }

  _loadLastSearchedLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastSearchedLocations = prefs.getStringList('lastSearchedLocations') ?? [];
    });
  }

  _saveLocation(String location) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!_lastSearchedLocations.contains(location)) {
      _lastSearchedLocations.add(location);
      await prefs.setStringList('lastSearchedLocations', _lastSearchedLocations);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Home Screen"),centerTitle: true,),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildSearchWidget()),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        _getWeatherData(_searchController.text);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (inProgress) CircularProgressIndicator(),
                _buildLastSearchedLocations(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchWidget() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Search Any Location",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildLastSearchedLocations() {
    if (_lastSearchedLocations.isEmpty) {
      return Container();
    }
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Searched Locations:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._lastSearchedLocations.map((location) => ListTile(
              title: Text(location),
              onTap: () {
                _searchController.text = location;
                _getWeatherData(location);
              },
            )),
          ],
        ),
      ),
    );
  }

  _getWeatherData(String location) async {
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a location")),
      );
      return;
    }

    setState(() {
      inProgress = true;
    });

    try {
      response = await WeatherApi().getCurrentWeather(location);
      if (response != null) {
        _saveLocation(location);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherDetailsPage(response: response, location: location),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No weather data found for this location")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get the weather")),
      );
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
