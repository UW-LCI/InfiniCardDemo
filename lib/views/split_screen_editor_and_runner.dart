import 'package:flutter/material.dart';
import 'package:infinicard_v1/views/infinicard_viewer.dart';
import 'package:infinicard_v1/views/source_editor.dart';
import 'package:infinicard_v1/widgets/canvas_widget.dart';
import 'package:split_view/split_view.dart';
import 'package:infinicard_v1/views/canvas.dart';

class SplitScreenEditorAndRunner extends StatefulWidget {
  const SplitScreenEditorAndRunner({super.key});

  @override
  State<SplitScreenEditorAndRunner> createState() =>
      _SplitScreenEditorAndRunnerState();
}

class _SplitScreenEditorAndRunnerState
    extends State<SplitScreenEditorAndRunner> {final GlobalKey<CanvasWidgetState> _canvasKey = GlobalKey<CanvasWidgetState>();
  bool showXML = false;

  @override
  Widget build(BuildContext context) {
    if (showXML == true) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Infinicard XML Editor'),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 50),
                child: IconButton(
                    onPressed: () {
                      setState((){showXML = !showXML;});
                    },
                    icon: const Icon(Icons.code)))
          ],
        ),
        body: SplitView(
          viewMode: SplitViewMode.Horizontal,
          indicator: const SplitIndicator(viewMode: SplitViewMode.Horizontal),
          controller: SplitViewController(weights:[.33,.33,.33]),
          children: [
            CanvasView(canvasKey: _canvasKey),
            SourceEditor(canvasKey: _canvasKey),
            const InfinicardViewer()
          ],
          
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Infinicard XML Editor'),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 50),
                child: IconButton(
                    onPressed: () {
                      setState((){showXML = !showXML;});
                    },
                    icon: const Icon(Icons.code)))],
        ),
        body: SplitView(
          viewMode: SplitViewMode.Horizontal,
          indicator: const SplitIndicator(viewMode: SplitViewMode.Horizontal),
          controller: SplitViewController(weights:[.5,.5]),
          children: [
            CanvasView(canvasKey: _canvasKey),
            const InfinicardViewer()
          ],
          
        ),
      );
    }
  }
}
