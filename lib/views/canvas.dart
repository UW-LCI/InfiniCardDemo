import 'package:flutter/material.dart';
import 'package:infinicard_v1/views/drawing_page.dart';

class CanvasView extends StatelessWidget {
  const CanvasView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Recognition App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DrawingPage(),
    );
  }
}