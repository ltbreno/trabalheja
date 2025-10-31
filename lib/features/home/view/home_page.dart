// lib/features/home/view/home_page.dart
import 'package:flutter/material.dart';   

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Inicial'),
      ),
      body: const Center(
        child: Text('Bem-vindo ao app TrabalheJá!'),
      ),
    );
  }
}