import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/home.dart';
import 'package:health/health.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

const List<HealthDataType> types = [
  HealthDataType.STEPS,
  HealthDataType.SLEEP_ASLEEP,
  HealthDataType.EXERCISE_TIME,
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
              icon: const Icon(Icons.mobile_friendly_sharp),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Building()));
              }),
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
      child: FutureBuilder(
        future: getDB(),
        builder: (context, snapshot) => snapshot.hasData
            ? Column(
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
                        itemCount: types.length,
                        itemBuilder: (context, index) {
                          String name =
                              types[index].name.toLowerCase().split("_")[0];
                          return SwitchListTile(
                              title: Row(
                                children: [
                                  Text(name.capitalize()),
                                  const Spacer(),
                                  snapshot.data!.get("name") == true
                                      ? SizedBox(
                                          width: 100,
                                          child: NumberPicker(
                                            value: snapshot.data!
                                                .get("goals")
                                                .get(types[index].name),
                                            minValue: 0,
                                            maxValue: 10000,
                                            onChanged: (val) {
                                              // change the value of the goal
                                              snapshot.data!.reference.set({
                                                "goals": {
                                                  types[index].name: val,
                                                }
                                              });

                                              setState(() {});
                                            },
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                              value:
                                  snapshot.data!.get(types[index].name) == null
                                      ? false
                                      : true,
                              onChanged: (val) {
                                // change set the goal to a default value depending on its name, switch
                                snapshot.data!.reference.set({
                                  types[index].name: val,
                                  "goals": {
                                    types[index].name: name == "steps"
                                        ? 10000
                                        : name == "sleep"
                                            ? 8
                                            : name == "exercise"
                                                ? 30
                                                : name == "water"
                                                    ? 2.0
                                                    : 0
                                  }
                                });
                                setState(() {});
                              });
                        }),
                  ),
                ],
              )
            : Container(),
      ),
    );
  }
}

class Building extends StatelessWidget {
  const Building({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: http.get("https://minjin.piythonanywhere.com/"),
        builder: (context, snapshot) => snapshot.hasData
            ? Text(snapshot.data.toString())
            : const CircularProgressIndicator());
  }
}
