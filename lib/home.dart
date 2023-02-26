import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/nav.dart';
import 'package:health/health.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
          future: Future.wait([getData(), getDB()]),
          builder: (context, snapshot) {
            final Map<String, double> hData =
                snapshot.data![1] as Map<String, double>;
            final doc = snapshot.data![2] as DocumentSnapshot;
            if (snapshot.hasData) {
              return SafeArea(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        ListView.builder(
                          itemCount: hData.entries.length,
                          itemBuilder: (context, index) {
                            return dataDisplay(
                              name: hData.entries.first.key,
                              data: hData.entries.first.value,
                              goal: doc.get("goal"),
                            );
                          },
                        ),
                        const Spacer(),
                        const Nav(),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Future<Map<String, double>> getData() async {
    final HealthFactory health = HealthFactory();
    // for every type, check sharedpreferences for a goal
    await health.requestAuthorization(types);
    // get the health data for today
    final DateTime date = DateTime.now();
    final DateTime startDate = DateTime(date.year, date.month, date.day);
    final List<HealthDataPoint> data = await health.getHealthDataFromTypes(
      startDate,
      date,
      types,
    );
    Map<String, double> dataMap = {};
    for (var point in data) {
      dataMap[point.type.name.toLowerCase()] =
          double.parse(point.value.toString());
    }
    return dataMap;
  }

  setDB(key, newVal) async {
    FirebaseFirestore.instance.collection("users").doc("demo").set({
      "goals": {
        key: newVal,
      }
    }, SetOptions(merge: true));
  }
}

Future<DocumentSnapshot<Map<String, dynamic>>> getDB() async {
  return (await FirebaseFirestore.instance
      .collection("users")
      .doc("demo")
      .get());
}

class dataDisplay extends StatelessWidget {
  final double data;
  final double goal;
  final String name;
  dataDisplay(
      {super.key, required this.data, required this.goal, required this.name});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    '[${"-" * ((data / goal * 15).round())} ${" " * ((15 - (data / goal * 15)).round())}]',
                    textStyle: GoogleFonts.ibmPlexMono(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    cursor: "█",
                    speed: const Duration(milliseconds: 300),
                  )
                ],
                isRepeatingAnimation: false,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: Row(
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    "$name: $data",
                    textStyle: GoogleFonts.ibmPlexMono(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    cursor: "█",
                    speed: const Duration(milliseconds: 300),
                  )
                ],
                isRepeatingAnimation: false,
              )
            ],
          ),
        ),
      ],
    );
  }
}
