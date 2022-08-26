import 'dart:async';
import 'dart:math';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

int maxSeconds = 30;
int seconds = maxSeconds;
Timer? timer;
bool isRunning = false, isPaused = false, isCompleted = false;

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget getFab() {
    return isRunning
        ? Container()
        : Builder(
            builder: (BuildContext context) => FloatingActionButton(
              onPressed: () async {
                Duration? resultingDuration = await showDurationPicker(
                  context: context,
                  initialTime: Duration(seconds: 30),
                );
                setState(() {
                  seconds = resultingDuration!.inSeconds;
                });

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Chose duration: ${resultingDuration}')));
              },
              tooltip: 'Popup Duration Picker',
              child: Icon(Icons.add),
            ),
          );
  }

  void showTimerPicker() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.25,
            width: double.infinity,
            color: Colors.white,
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hms,
              initialTimerDuration: Duration(hours: 0, minutes: 0, seconds: 30),
              onTimerDurationChanged: (value) {
                setState(() {
                  maxSeconds = value.inSeconds;
                  seconds = maxSeconds;
                });
              },
            ),
          );
        });
  }

  void startTimer() {
    setState(() {
      isRunning = true;
      isPaused = false;
    });

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        setState(() {
          isCompleted = true;
          isRunning = false;
        });
      }
    });
  }

  void ResetTimer() {
    setState(() {
      timer?.cancel();
      seconds = maxSeconds;
      isRunning = false;
      isCompleted = false;
      isPaused = false;
    });
  }

  void PauseTimer() {
    setState(() {
      timer?.cancel();

      isPaused = true;
    });
  }

  Widget buildWidget() {
    return isCompleted == true
        ? ElevatedButton(
            onPressed: ResetTimer,
            child: Text("Reset Timer"),
          )
        : isRunning == false
            ? ElevatedButton(
                onPressed: startTimer,
                child: Text("Start Timer"),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 5),
                    child: ElevatedButton(
                      onPressed: isPaused == false ? PauseTimer : startTimer,
                      child: isPaused == false ? Text("Pause") : Text("Resume"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: ElevatedButton(
                      onPressed: ResetTimer,
                      child: Text("Cancel"),
                    ),
                  ),
                ],
              );
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    double _h = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(children: [
          Container(
            width: _w,
            height: _h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.indigo],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                stops: [0.4, 0.7],
                tileMode: TileMode.repeated,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isCompleted == false
                  ? Container(
                      margin: EdgeInsets.only(bottom: 30),
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Stack(fit: StackFit.expand, children: [
                          CircularProgressIndicator(
                            value: seconds / maxSeconds,
                            strokeWidth: 6,
                            color: Colors.white,
                          ),
                          Center(
                            child: isRunning == true
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${(seconds / 3600).toInt()}H:",
                                        style: TextStyle(
                                            fontSize: 30, color: Colors.white),
                                      ),
                                      Text(
                                        "${((seconds / 60) % 60).toInt()}M:",
                                        style: TextStyle(
                                            fontSize: 30, color: Colors.white),
                                      ),
                                      Text(
                                        "${(seconds % 60).toInt()}S",
                                        style: TextStyle(
                                            fontSize: 30, color: Colors.white),
                                      ),
                                    ],
                                  )
                                : CupertinoButton(
                                    child: Text(
                                      "${(seconds / 3600).toInt()}H:${((seconds / 60) % 60).toInt()}M:${(seconds % 60).toInt()}S",
                                      style: TextStyle(
                                          fontSize: 30, color: Colors.white),
                                    ),
                                    onPressed: showTimerPicker),
                          ),
                        ]),
                      ),
                    )
                  : Container(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 200,
                        color: Colors.green.shade200,
                      ),
                    ),
              buildWidget(),
            ],
          ),
        ]),
        floatingActionButton: getFab(),
      ),
    );
  }
}
