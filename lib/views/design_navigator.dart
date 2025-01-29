import 'package:flutter/material.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:infinicard_v1/views/canvas.dart';
import 'package:infinicard_v1/views/infinicard_viewer.dart';
import 'package:infinicard_v1/views/source_editor.dart';
import 'package:infinicard_v1/widgets/canvas_widget.dart';
import 'package:infinicard_v1/widgets/design_window.dart';
import 'package:provider/provider.dart';
import 'package:split_view/split_view.dart';

class DesignNavigator extends StatefulWidget {
  final GlobalKey<CanvasWidgetState> canvasKey;
  const DesignNavigator(
      {super.key, required this.canvasKey});

  @override
  State<DesignNavigator> createState() => _DesignNavigatorState();
}

class _DesignNavigatorState extends State<DesignNavigator> {
  
  @override
  Widget build(BuildContext context) {
    InfinicardStateProvider provider = Provider.of<InfinicardStateProvider>(context, listen: true);
    Map views = {
      "draw": DesignWindow(view: CanvasView(canvasKey: widget.canvasKey), type:"draw"),
      "render": DesignWindow(view: InfinicardViewer(), type:"render"),
      "xml": DesignWindow(view: SourceEditor(canvasKey: widget.canvasKey), type:"xml")
    };
    List<Widget> activeViews = [];
    for(String view in provider.activeViews){
      activeViews.add(views[view]);
    }
    // return Scaffold(body: Row(children:activeViews));
    List<double> viewWeights = List.generate(activeViews.length, (index) => 1/activeViews.length);
    return Scaffold(body: SplitView(
        viewMode: SplitViewMode.Horizontal,
        indicator: const SplitIndicator(viewMode: SplitViewMode.Horizontal),
        controller: SplitViewController(weights:viewWeights),
        children: activeViews));
  }
}
