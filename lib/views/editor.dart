import 'package:flutter/material.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:infinicard_v1/views/design_navigator.dart';
import 'package:infinicard_v1/views/file_navigator.dart';
import 'package:infinicard_v1/views/infinicard_viewer.dart';
import 'package:infinicard_v1/views/source_editor.dart';
import 'package:infinicard_v1/widgets/canvas_widget.dart';
import 'package:provider/provider.dart';
import 'package:split_view/split_view.dart';
import 'package:infinicard_v1/views/canvas.dart';

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() =>
      _EditorState();
}

class _EditorState
    extends State<Editor> {final GlobalKey<CanvasWidgetState> _canvasKey = GlobalKey<CanvasWidgetState>();

  @override
  Widget build(BuildContext context) {
    
    // final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinicard'),
      ),
      body: SplitView(
        viewMode: SplitViewMode.Horizontal,
        indicator: const SplitIndicator(viewMode: SplitViewMode.Horizontal),
        controller: SplitViewController(weights:[.1,.9]),
        children: [
          FileNavigator(),
          DesignNavigator(canvasKey: _canvasKey)
        ],
        
      ),
    );
    
    }
}
