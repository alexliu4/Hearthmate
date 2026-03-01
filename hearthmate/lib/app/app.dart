import 'package:flutter/material.dart';

import '../features/pomodoro/presentation/screens/home_screen.dart';

class HearthmateApp extends StatelessWidget {
  const HearthmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hearthmate',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF7043)),
      ),
      home: const PomodoroHomeScreen(),
    );
  }
}
