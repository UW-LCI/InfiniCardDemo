import 'package:flutter/material.dart';
import 'package:infinicard_v1/views/infinicard_viewer.dart';
import 'package:infinicard_v1/views/source_editor.dart';
import 'package:split_view/split_view.dart';
import 'package:infinicard_v1/views/canvas.dart';

class SplitScreenEditorAndRunner extends StatelessWidget {
  const SplitScreenEditorAndRunner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinicard XML Editor'),
      ),
      body: SplitView(
        viewMode: SplitViewMode.Horizontal,
        indicator: const SplitIndicator(viewMode: SplitViewMode.Horizontal),
        children: const [
          CanvasView(),
          SourceEditor(),
          InfinicardViewer(),
        ],
      ),
    );
  }
}