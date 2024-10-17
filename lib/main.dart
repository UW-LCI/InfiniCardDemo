import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:infinicard_v1/views/split_screen_editor_and_runner.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (context) => InfinicardStateProvider(),
        child: const SplitScreenEditorAndRunner(),
      ),
    );
  }
}
