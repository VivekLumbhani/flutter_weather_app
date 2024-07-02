import 'dart:convert';

import 'package:weatherapp/constans/constants.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/modals/weatherModal.dart';
class WeatherApi{
  final String baseUrl="https://api.weatherapi.com/v1/current.json";

  Future<ApiResponse> getCurrentWeather(String location)async{
    String apiUrl="$baseUrl?key=$apikey&q=$location";
    try{

      final  response=await http.get(Uri.parse(apiUrl));

      if(response.statusCode==200){
        return ApiResponse.fromJson(jsonDecode(response.body));
      }else{
        throw Exception("Failed to load weather");
      }

    }catch(e){

      print("error in fetching from url $e");
      throw Exception("Failed to load weather");

    }
  }
}