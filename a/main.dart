import 'package:flutter/material.dart';

import 'Task_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Task App',
        debugShowCheckedModeBanner: false,
        home: TaskListScreen());
  }
}
