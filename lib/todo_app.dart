import 'package:flutter/material.dart';
import 'todo_list_screen.dart';

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskNote App',
      theme: ThemeData(
        primaryColor: Colors.greenAccent,
        colorScheme: ColorScheme.light(
          primary: Colors.redAccent,
          secondary: Colors.deepOrangeAccent,
        ),
      ),
      home: TodoListScreen(),
    );
  }
}
