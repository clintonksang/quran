import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:quran_app/utils/export_utils.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';

class PrayerTime {
  late final PrayerTimes _prayerTimes;

  PrayerTime(double latitude, double longitude) {
    final myCoordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;
    _prayerTimes = PrayerTimes.today(myCoordinates, params);
  }

  String getNextPrayerTime(AsyncSnapshot<DateTime> snapshot) {
    final List<Map<String, DateTime>> prayerTimes = [
      {'Fajr': _prayerTimes.fajr},
      {'Sunrise': _prayerTimes.sunrise},
      {'Dhuhr': _prayerTimes.dhuhr},
      {'Asr': _prayerTimes.asr},
      {'Maghrib': _prayerTimes.maghrib},
      {'Isha': _prayerTimes.isha},
    ];

    prayerTimes.sort((a, b) => a.values.first.isAfter(b.values.first) ? 1 : -1);

    for (Map<String, DateTime> prayer in prayerTimes) {
      if (snapshot.data!.isBefore(prayer.values.first)) {
        return '${prayer.keys.first} : ${DateFormat.jm().format(prayer.values.first)}';
      }
    }

    // If all prayer times have passed, return the first prayer time of the next day
    final Map<String, DateTime> nextDayPrayer = prayerTimes.first;
    return '${nextDayPrayer.keys.first} : ${DateFormat.jm().format(nextDayPrayer.values.first.add(Duration(days: 1)))}';
  }

  void getPrayerTimes() {}
}
