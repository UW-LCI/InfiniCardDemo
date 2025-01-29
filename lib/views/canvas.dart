import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/canvasTheme.dart';
import 'package:infinicard_v1/views/drawing_page.dart';
import 'package:infinicard_v1/widgets/canvas_widget.dart';

class CanvasView extends StatelessWidget {
  final GlobalKey<CanvasWidgetState> canvasKey;

  const CanvasView({super.key, required this.canvasKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'Drawing Recognition App',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      //   scaffoldBackgroundColor: CanvasTheme.backgroundColor,
      // ),
      home: DrawingPage(canvasKey: canvasKey),
    );
  }
}