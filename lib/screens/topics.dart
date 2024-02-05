import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:quran_app/screens/chat.dart';

class ReligiousTopicsCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> religiousTopics = [
      'Faith',
      'Anxiety',
      'Family',

      // Add more topics here
    ];

    return CarouselSlider(
      options: CarouselOptions(
        pageSnapping: true,
        aspectRatio: 16 / 2,
        autoPlay: true,
        enlargeCenterPage: false,
        viewportFraction: 0.34,
        // aspectRatio: 2.0,
        initialPage: 1,
      ),
      items: religiousTopics.map((topic) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>   ChatPage(prompt: topic)),
            );
               // Navigator.push(context,MaterialPageRoute(builder:  ChatPage(prompt: 'topic'));
              },
              child: Container(
                child: Center(
                  child: Text(
                    topic,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                // width: MediaQuery.of(context).size.width * .7,
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                    color: Color(0XFFFCD48F),
                    borderRadius: BorderRadius.circular(25)),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
