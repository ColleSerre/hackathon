import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health/health.dart';
import 'package:numberpicker/numberpicker.dart';

Map<String, dynamic> db = {
  "steps": 10000,
  "water": 10,
  "sleep": 8,
};

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic> db = {
    "steps": 10000,
    "water": 10,
    "sleep": 8,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final Map<String, String> hData = snapshot.data!;
              return SafeArea(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: hData.entries.length,
                            itemBuilder: (context, index) {
                              final goal = db[hData.values.toList()[index]];
                              final name = db.keys.toList()[index];
                              final data = hData.values.toList()[index];
                              // only render dataDisplay if goal, name and data aren't null
                              return dataDisplay(
                                name: name,
                                data: double.parse(data),
                                goal: goal,
                              );
                            },
                          ),
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

  Future<Map<String, String>> getData() async {
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
    Map<String, String> dataMap = {};
    for (var point in data) {
      dataMap[point.type.name.toLowerCase()] = point.value.toString();
    }
    return dataMap;
  }

  setDB(key, newVal) {
    return {
      ...db,
      key: newVal,
    };
  }
}

class dataDisplay extends StatefulWidget {
  double data;
  double goal;
  final String name;
  dataDisplay(
      {super.key, required this.data, required this.goal, required this.name});

  @override
  State<dataDisplay> createState() => _dataDisplayState();
}

class _dataDisplayState extends State<dataDisplay> {
  @override
  Widget build(BuildContext context) {
    switch (widget.name) {
      case "steps":
        widget.data = 5000;
        break;
      case "water":
        widget.data = 600;
        break;
      case "sleep":
        widget.data = 7.3;
        break;
    }
    // set default values for widget.goal using switch statement on widget.name
    switch (widget.name) {
      case "steps":
        widget.goal = 10000;
        break;
      case "water":
        widget.goal = 1500;
        break;
      case "sleep":
        widget.goal = 8;
        break;
    }
    final int barLength = 20;
    final double progress = widget.data / widget.goal;
    final int numChars = (progress * barLength).floor();
    final String bar = '=' * numChars + ' ' * (barLength - numChars);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: Row(
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    "${widget.name.capitalize()}: ${widget.data.toInt()} / ${widget.goal.toInt()}",
                    textStyle: GoogleFonts.ibmPlexMono(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    cursor: "|",
                    speed: const Duration(milliseconds: 100),
                  )
                ],
                isRepeatingAnimation: false,
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    '[$bar]',
                    textStyle: GoogleFonts.ibmPlexMono(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    cursor: "|",
                    speed: const Duration(milliseconds: 100),
                  )
                ],
                isRepeatingAnimation: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

const List<HealthDataType> types = [
  HealthDataType.STEPS,
  HealthDataType.SLEEP_ASLEEP,
  HealthDataType.WATER,
];

class Nav extends StatelessWidget {
  const Nav({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      margin: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              icon: const Icon(Icons.mobile_friendly_sharp), onPressed: () {}),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.white),
            ),
            child: TextButton(
                child: Text(
                  "Set Goals",
                  style: GoogleFonts.ibmPlexMono(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      builder: (context) => const SettingSheet());
                }),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

@override
class SettingSheet extends StatefulWidget {
  const SettingSheet({
    super.key,
  });

  @override
  State<SettingSheet> createState() => _SettingSheetState();
}

class _SettingSheetState extends State<SettingSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              "Set Goals",
              style: GoogleFonts.ibmPlexMono(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: db.entries.toList().length,
                  itemBuilder: (context, index) {
                    String name = types[index].name.toLowerCase().split("_")[0];
                    return SwitchListTile(
                        title: Row(
                          children: [
                            Text(name),
                            const Spacer(),
                            db.values.toList()[index] == true
                                ? SizedBox(
                                    width: 100,
                                    child: NumberPicker(
                                      value: db.values.toList()[index],
                                      minValue: 0,
                                      maxValue: 10000,
                                      onChanged: (val) {
                                        // change the value of the goal
                                        db[db.entries.toList()[index].key] =
                                            val;
                                        setState(() {});
                                      },
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        value: db.values.toList()[index] == null ? false : true,
                        onChanged: (val) {
                          // change set the goal to a default value depending on its name, switch
                          final name = db.entries.toList()[index].key;
                          val
                              ? db[name] = db[name] == "steps"
                                  ? 10000
                                  : db[name] == "water"
                                      ? 2000
                                      : db[name] == "sleep"
                                          ? 8
                                          : 0
                              : db[name] = null;

                          setState(() {});
                        });
                  }),
            ),
          ],
        ));
  }
}
