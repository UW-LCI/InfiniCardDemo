// control_panel_widget.dart

import 'package:flutter/material.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:provider/provider.dart';

class ControlPanelWidget extends StatefulWidget {
  final VoidCallback onRecognize;

  const ControlPanelWidget({
    super.key,
    required this.onRecognize,
  });

  @override
  ControlPanelWidgetState createState() => ControlPanelWidgetState();
}

class ControlPanelWidgetState extends State<ControlPanelWidget> {
  String selected = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _clear(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[50]),
            child: const Icon(Icons.delete),
          ),
          ElevatedButton(
            onPressed: widget.onRecognize,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[50]),
            child: const Icon(Icons.lightbulb),
          ),
          ElevatedButton(
            onPressed: () => _undo(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[50]),
            child: const Icon(Icons.undo),
          ),
          ElevatedButton(
            onPressed: () => _redo(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[50]),
            child: const Icon(Icons.redo),
          ),
          ElevatedButton(
            onPressed: () => _cursor(context),
            style: ElevatedButton.styleFrom(backgroundColor: selected == "select" ? Colors.purple[200] : Colors.purple[50]),
            child: const Icon(Icons.ads_click),
          ),
          ElevatedButton(
            onPressed: () => _line(context),
            style: ElevatedButton.styleFrom(backgroundColor: selected == "line" ? Colors.purple[200] : Colors.purple[50]),
            child: const Icon(Icons.edit),
          ),
          ElevatedButton(
            onPressed: () => _stroke(context),
            style: ElevatedButton.styleFrom(backgroundColor: selected == "stroke" ? Colors.purple[200] : Colors.purple[50]),
            child: const Icon(Icons.brush),
          ),
          ElevatedButton(
            onPressed: () => _erase(context),
            child: const Icon(Icons.auto_fix_normal),
            style: ElevatedButton.styleFrom(backgroundColor: selected == "erase" ? Colors.purple[200] : Colors.purple[50]),
          ),
          ElevatedButton(
            onPressed: () => _box(context),
            child: const Icon(Icons.rectangle_outlined),
            style: ElevatedButton.styleFrom(backgroundColor: selected == "box" ? Colors.purple[200] : Colors.purple[50]),
          ),
          // ElevatedButton(
          //   onPressed: onDraw,
          //   child: const Icon(Icons.create),
          // ),
          // ElevatedButton(
          //   onPressed: onErase,
          //   child: const Icon(Icons.auto_fix_normal),
          // ),
          // ElevatedButton(
          //   onPressed: onSave,
          //   child: const Text('Save'),
          // ),
        ],
      ),
    );
  }

  void _undo(BuildContext context){
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    provider.undo();
  }

  void _clear(BuildContext context){
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    provider.clear();
  }

  void _redo(BuildContext context){
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    provider.redo();
  }

  void _line(BuildContext context){
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    provider.toolSelected = Tools.line;
    setState(() {
      selected = "line";
    });
  }

  void _stroke(BuildContext context){
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    provider.toolSelected = Tools.stroke;
    setState(() {
      selected = "stroke";
    });
  }

  void _erase(BuildContext context){
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    provider.toolSelected = Tools.erase;
    setState(() {
      selected = "erase";
    });
  }

  void _box(BuildContext context){
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    provider.toolSelected = Tools.box;
    setState(() {
      selected = "box";
    });
  }

  void _cursor(BuildContext context){
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    provider.toolSelected = Tools.select;
    setState(() {
      selected = "select";
    });
  }
}
