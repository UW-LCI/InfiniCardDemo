// control_panel_widget.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/canvasTheme.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:provider/provider.dart';

class ControlPanelWidget extends StatelessWidget {
  // final VoidCallback onClear;
  final VoidCallback onRecognize;
  // final VoidCallback onSave;
  // final VoidCallback onUndo;
  // final VoidCallback onRedo;
  // final VoidCallback onDraw;
  // final VoidCallback onErase;

  const ControlPanelWidget({
    super.key,
    // required this.onClear,
    required this.onRecognize,
    // required this.onSave,
    // required this.onUndo,
    // required this.onRedo,
    // required this.onDraw,
    // required this.onErase
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _clear(context),
            child: const Icon(Icons.delete),
          ),
          ElevatedButton(
            onPressed: onRecognize,
            child: const Icon(Icons.lightbulb),
          ),
          ElevatedButton(
            onPressed: () => _undo(context),
            child: const Icon(Icons.undo),
          ),
          ElevatedButton(
            onPressed: () => _redo(context),
            child: const Icon(Icons.redo),
          ),
          ElevatedButton(
            onPressed: () => _cursor(context),
            child: const Icon(Icons.ads_click),
          ),
          ElevatedButton(
            onPressed: () => _line(context),
            child: const Icon(Icons.edit),
          ),
          ElevatedButton(
            onPressed: () => _stroke(context),
            child: const Icon(Icons.brush),
          ),
          ElevatedButton(
            onPressed: () => _erase(context),
            child: const Icon(Icons.auto_fix_normal),
          ),
          ElevatedButton(
            onPressed: () => _box(context),
            child: const Icon(Icons.rectangle_outlined),
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
  }

  void _stroke(BuildContext context){
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    provider.toolSelected = Tools.stroke;
  }

  void _erase(BuildContext context){
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    provider.toolSelected = Tools.erase;
  }

  void _box(BuildContext context){
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    provider.toolSelected = Tools.box;
  }

  void _cursor(BuildContext context){
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    provider.toolSelected = Tools.select;
  }
}
