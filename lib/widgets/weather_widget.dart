import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherWidget extends StatefulWidget {
  final bool isDark;

  const WeatherWidget({super.key, required this.isDark});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String temp = '--';
  String iconCode = '01d';
  bool isLoading = true;
  bool isError = false;

  // TODO: Replace with your actual OpenWeather API Key
  final String apiKey = 'YOUR_API_KEY_HERE';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final url = 'https://api.openweathermap.org/data/2.5/weather?q=Barisal,bd&units=metric&appid=$apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temp = data['main']['temp'].round().toString();
          iconCode = data['weather'][0]['icon'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isError) {
      // You can return a small error icon or an empty box if failing
      return const SizedBox.shrink(); 
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: isLoading 
        ? SizedBox(
            width: 20, 
            height: 20, 
            child: CircularProgressIndicator(
              strokeWidth: 2, 
              color: widget.isDark ? Colors.white : Colors.blueGrey,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://openweathermap.org/img/wn/$iconCode@2x.png',
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.wb_sunny, 
                  color: widget.isDark ? Colors.white70 : Colors.orange, 
                  size: 20,
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$temp°C',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : Colors.black87,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Barishal',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: widget.isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }
}
