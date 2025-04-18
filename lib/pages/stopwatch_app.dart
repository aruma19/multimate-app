import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchPage extends StatefulWidget {
  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  int _seconds = 0;

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      setState(() {});
    });
  }

  void _startStopwatch() {
    _stopwatch.start();
    _startTimer();
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _timer.cancel();
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    setState(() {});
  }

  @override
  void dispose() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    }
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;
    final timeStr =
        '${elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}:${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}.${(elapsed.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text("Stopwatch")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(timeStr, style: TextStyle(fontSize: 48)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _startStopwatch, child: Text("Start")),
                SizedBox(width: 10),
                ElevatedButton(onPressed: _stopStopwatch, child: Text("Stop")),
                SizedBox(width: 10),
                ElevatedButton(onPressed: _resetStopwatch, child: Text("Reset")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
