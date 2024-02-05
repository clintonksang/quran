import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimeApi {
  final String baseUrl = 'http://api.aladhan.com/v1/calendar/';

  Future<List<Map<String, String>>> getPrayerTimes(int year, int month) async {
    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Make API request
      String url =
          '$baseUrl$year/$month?latitude=${position.latitude}&longitude=${position.longitude}';
      Response response = await Dio().get(url);

      // Parse response
      if (response.statusCode == 200) {
        List<Map<String, String>> prayerTimesList = [];
        List<dynamic> data = response.data['data'];

        for (var prayerTimeData in data) {
          Map<String, String> prayerTimes = {};
          Map<String, dynamic> timings = prayerTimeData['timings'];
          prayerTimes['Fajr'] = timings['Fajr'];
          prayerTimes['Sunrise'] = timings['Sunrise'];
          prayerTimes['Dhuhr'] = timings['Dhuhr'];
          prayerTimes['Asr'] = timings['Asr'];
          prayerTimes['Sunset'] = timings['Sunset'];
          prayerTimes['Maghrib'] = timings['Maghrib'];
          prayerTimes['Isha'] = timings['Isha'];
          prayerTimes['Imsak'] = timings['Imsak'];
          prayerTimes['Midnight'] = timings['Midnight'];

          prayerTimesList.add(prayerTimes);
        }

        return prayerTimesList;
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
