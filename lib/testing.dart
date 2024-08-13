import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AnalogClock extends StatefulWidget {
  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 3.0),
        ),
        child: CustomPaint(
          painter: ClockPainter(_now),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime _dateTime;

  ClockPainter(this._dateTime);

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);
    double radius = min(centerX, centerY);

    // Draw Clock Circle
    Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw Numbers
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    double angleStep = 2 * pi / 12;
    for (int i = 1; i <= 12; i++) {
      double angle = -pi / 2 + angleStep * i;
      double x = centerX + cos(angle) * radius * 0.85;
      double y = centerY + sin(angle) * radius * 0.85;
      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(fontSize: 20, color: Colors.black),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw Hour Hand
    double hourX = centerX +
        radius *
            0.4 *
            cos((_dateTime.hour * 30 + _dateTime.minute * 0.5) * pi / 180);
    double hourY = centerY +
        radius *
            0.4 *
            sin((_dateTime.hour * 30 + _dateTime.minute * 0.5) * pi / 180);
    canvas.drawLine(center, Offset(hourX, hourY), Paint()..color = Colors.black);

    // Draw Minute Hand
    double minuteX =
        centerX + radius * 0.6 * cos(_dateTime.minute * 6 * pi / 180);
    double minuteY =
        centerY + radius * 0.6 * sin(_dateTime.minute * 6 * pi / 180);
    canvas.drawLine(
        center, Offset(minuteX, minuteY), Paint()..color = Colors.black);

    // Draw Second Hand
    double secondX =
        centerX + radius * 0.8 * cos(_dateTime.second * 6 * pi / 180);
    double secondY =
        centerY + radius * 0.8 * sin(_dateTime.second * 6 * pi / 180);
    canvas.drawLine(
        center, Offset(secondX, secondY), Paint()..color = Colors.red);

    // Draw Center Dot
    Paint centerDotPaint = Paint()..color = Colors.black;
    canvas.drawCircle(center, 5, centerDotPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}