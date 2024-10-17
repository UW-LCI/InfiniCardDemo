import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';

class InfinicardViewer extends StatelessWidget {
  const InfinicardViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InfinicardStateProvider>(
      builder: (context, value, child) =>value.widget,
    );
  }
}