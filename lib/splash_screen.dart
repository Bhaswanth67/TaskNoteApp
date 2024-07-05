import 'dart:async';
import 'package:flutter/material.dart';
import 'todo_app.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _titleOpacity = 0.0;
  double _nameOpacity = 0.0;
  double _nameOffset = -100.0;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      // Navigate to the TodoApp after 5 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoApp()),
      );
    });

    // Start animations after a short delay
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _titleOpacity = 1.0;
      });

      Future.delayed(Duration(milliseconds: 800), () {
        setState(() {
          _nameOpacity = 1.0;
          _nameOffset = 0.0;
        });
      });

      Future.delayed(Duration(milliseconds: 4000), () {
        setState(() {
          _nameOpacity = 0.0;
          _nameOffset = 100.0;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated title
            AnimatedOpacity(
              opacity: _titleOpacity,
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
              child: Text(
                'TaskNote',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Animated 'Made by Bhaswanth'
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _nameOpacity),
              duration: Duration(seconds: 1),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(_nameOffset * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Text(
                'Made by Bhaswanth',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskNote',
      home: SplashScreen(),
    );
  }
}
