import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importa a nossa tela inicial

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeeCreative',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(), // O app inicializa na HomeScreen
    );
  }
}