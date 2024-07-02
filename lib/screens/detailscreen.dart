import 'package:flutter/material.dart';
import 'package:weatherapp/api/api.dart';
import 'package:weatherapp/modals/weatherModal.dart';

class WeatherDetailsPage extends StatefulWidget {
  final ApiResponse? response;
  final String location;
  const WeatherDetailsPage({Key? key, this.response, required this.location}) : super(key: key);

  @override
  _WeatherDetailsPageState createState() => _WeatherDetailsPageState();
}

class _WeatherDetailsPageState extends State<WeatherDetailsPage> {
  ApiResponse? response;
  bool inProgress = false;

  @override
  void initState() {
    super.initState();
    response = widget.response;
  }

  Future<void> _refreshWeatherData() async {
    setState(() {
      inProgress = true;
    });
    try {
      response = await WeatherApi().getCurrentWeather(widget.location);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to refresh the weather")),
      );
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Weather Details'),centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshWeatherData,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: inProgress
                ? Center(child: CircularProgressIndicator())
                : _buildWeatherWidget(),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherWidget() {
    if (response == null) {
      return Center(child: Text("No data available"));
    } else {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 50,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    response?.location?.name ?? "",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              response?.location?.country ?? "",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    (response?.current?.tempC.toString() ?? "") + " °c",
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    (response?.current?.condition?.text.toString() ?? ""),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: SizedBox(
                height: 200,
                child: Image.network(
                  "https:${response?.current?.condition?.icon}"
                      .replaceAll("64x64", "128x128"),
                  scale: 0.7,
                ),
              ),
            ),
            Card(
              elevation: 4,
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _dateAndTimeWidget("Humidity",
                          (response?.current?.humidity?.toString() ?? "") + " %"),
                      _dateAndTimeWidget("Wind Speed",
                          response?.current?.windKph?.toString() ?? ""),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _dateAndTimeWidget("Local Time",
                          response?.location?.localtime?.split(" ").last ?? ""),
                      _dateAndTimeWidget("Local Date",
                          response?.location?.localtime?.split(" ").first ?? ""),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _dateAndTimeWidget(String title, String data) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Text(
            data,
            style: TextStyle(
                color: Colors.black87, fontSize: 27, fontWeight: FontWeight.w600),
          ),
          Text(
            title,
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
