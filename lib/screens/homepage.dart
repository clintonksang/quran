import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quran_app/screens/topics.dart';
import 'package:quran_app/utils/export_utils.dart';
import 'package:intl/intl.dart';
import '../services/prayertime.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late StreamController<DateTime> _timeController;
  late final PrayerTime _prayerTime;
  late final DateTime time;
  String dailyQuote = '';
  List<Widget>? topics = [
    // "Anxiety",
    // "Pain"
    //     "Faith",
    // "Family",
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    // Adding a status listener to repeat the animation endlessly
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _prayerTime = PrayerTime(-1.14803, 36.96059);
    // initialize time
    // time = DateTime();
    // prayer timeisUpcomingPrayerTime

    _prayerTime.getPrayerTimes();

    // // Initialize the StreamController with the current time
    _timeController = StreamController<DateTime>.broadcast();
    _timeController.add(DateTime.now());

    // Update the time every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      _timeController.add(DateTime.now());
    });

    loadQuote();
  }

  Future<void> loadQuote() async {
    String data = await rootBundle.loadString('assets/verse.json');
    Map<String, dynamic> quotes = json.decode(data);
    setState(() {
      dailyQuote = getRandomQuote(quotes);
    });
  }

  String getRandomQuote(Map<String, dynamic> quotes) {
    Random random = Random();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int index = random.nextInt(quotes.length) + 1;
    return 'Daily Dua \n\n${quotes[index.toString()]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbarBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 85,
                  ),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Upcoming Prayer:',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                // color: Colors.white,
                                // fontSize: 18,
                                ),
                          ),
                        ),
                        // SizedBox(height: 8),
                        StreamBuilder<DateTime>(
                          stream: _timeController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                "${_prayerTime.getNextPrayerTime(snapshot)}",
                                style: TextStyle(
                                    fontSize: 24,
                                    // color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              );
                            } else {
                              return Text(
                                'Loading...',
                                style: TextStyle(
                                    // color: Colors.white,
                                    ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Lottie.asset(
                    'assets/lottie/islam2.json',
                    width: 135,
                    controller: _controller,
                    onLoaded: (composition) {
                      // Configure the AnimationController with the duration of the
                      // Lottie file and start the animation.
                      _controller
                        ..duration = Duration(milliseconds: 5500)
                        ..forward();
                    },
                  ),
                ),
              ],
            ),

            // daily text
            SizedBox(
              height: 20,
            ),

            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.deepPurple[900],
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/sinan.jpg')),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  // color: Colors.red,
                  height: 150,
                  width: 250,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      dailyQuote,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ),
            ),

            // Chat Section
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ask about ",
                    style: TextStyle(
                        // fontSize: 15,
                        // color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "View All",
                    style: TextStyle(
                        // fontSize: 15,
                        color: Color(0XFFFCD48F),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ReligiousTopicsCarousel(),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
