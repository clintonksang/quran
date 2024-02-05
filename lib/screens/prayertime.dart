import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clay_containers/clay_containers.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({Key? key}) : super(key: key);

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  late PrayerTimes _prayerTimes;
  bool isNotificationEnabled = false;
  late StreamController<DateTime> _timeController;

  @override
  void initState() {
    super.initState();
    getPrayerTimes();

    // Initialize the StreamController with the current time
    _timeController = StreamController<DateTime>.broadcast();
    _timeController.add(DateTime.now());

    // Update the time every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      _timeController.add(DateTime.now());
    });
  }

  void getPrayerTimes() {
    final myCoordinates = Coordinates(
        -1.14803, 36.96059); // Replace with your own location lat, lng.
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;
    _prayerTimes = PrayerTimes.today(myCoordinates, params);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prayer Times'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                isNotificationEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: isNotificationEnabled ? Colors.green : Colors.red,
              ),
              onPressed: () {
                setState(() {
                  isNotificationEnabled = !isNotificationEnabled;
                  // Add logic to handle notification toggle
                });
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Time Card
              ClayContainer(
                depth: 20,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Time:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      StreamBuilder<DateTime>(
                        stream: _timeController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              DateFormat.jm().format(snapshot.data!),
                              style: TextStyle(fontSize: 24),
                            );
                          } else {
                            return Text('Loading...');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Upcoming Prayer Time Card
              ClayContainer(
                depth: 20,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upcoming Prayer Time:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      StreamBuilder<DateTime>(
                        stream: _timeController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              getNextPrayerTime(snapshot),
                              style: TextStyle(fontSize: 24),
                            );
                          } else {
                            return Text('Loading...');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // All Prayer Times
              ClayContainer(
                depth: 20,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Prayer Times:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PrayerTimeTile('Fajr', _prayerTimes.fajr),
                          PrayerTimeTile('Sunrise', _prayerTimes.sunrise),
                          PrayerTimeTile('Dhuhr', _prayerTimes.dhuhr),
                          PrayerTimeTile('Asr', _prayerTimes.asr),
                          PrayerTimeTile('Maghrib', _prayerTimes.maghrib),
                          PrayerTimeTile('Isha', _prayerTimes.isha),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  @override
  void dispose() {
    _timeController.close();
    super.dispose();
  }
}

class PrayerTimeTile extends StatelessWidget {
  final String title;
  final DateTime time;

  PrayerTimeTile(this.title, this.time);

  @override
  Widget build(BuildContext context) {
    final currentTime = DateTime.now();
    final isCurrentPrayerTime = time.isAfter(currentTime) &&
        time.isBefore(currentTime.add(Duration(minutes: 30)));
    final isUpcomingPrayerTime =
        time.isAfter(currentTime) && !isCurrentPrayerTime;

    // Calculate hours remaining until the upcoming prayer time
    final hoursRemaining =
        isUpcomingPrayerTime ? time.difference(currentTime).inHours : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClayContainer(
        depth: isCurrentPrayerTime ? 20 : (isUpcomingPrayerTime ? 15 : 10),
        color: isCurrentPrayerTime
            ? Colors.blueGrey
            : (isUpcomingPrayerTime ? Colors.grey : Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16),
                  ),
                  if (isUpcomingPrayerTime)
                    Text(
                      '(${hoursRemaining}h remaining)',
                      style: TextStyle(fontSize: 14, color: Colors.green),
                    ),
                ],
              ),
              Text(
                DateFormat.jm().format(time),
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// class PrayerTimeTile extends StatelessWidget {
//   final String title;
//   final DateTime time;

//   PrayerTimeTile(this.title, this.time);

//   @override
//   Widget build(BuildContext context) {
//     final currentTime = DateTime.now();
//     final isCurrentPrayerTime = time.isAfter(currentTime) &&
//         time.isBefore(currentTime.add(Duration(minutes: 30)));
//     final isUpcomingPrayerTime =
//         time.isAfter(currentTime) && !isCurrentPrayerTime;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: ClayContainer(
//         depth: isCurrentPrayerTime ? 20 : (isUpcomingPrayerTime ? 15 : 10),
//         color: isCurrentPrayerTime
//             ? Colors.blueGrey // Dark color for the current prayer time
//             : (isUpcomingPrayerTime
//                 ? Colors.grey
//                 : Colors.white), // Darker color for upcoming prayer time
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 16),
//               ),
//               Text(
//                 DateFormat.jm().format(time),
//                 style: TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
