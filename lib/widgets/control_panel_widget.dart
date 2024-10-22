// control_panel_widget.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ControlPanelWidget extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onRecognize;
  final VoidCallback onSave;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  // final VoidCallback onDraw;
  // final VoidCallback onErase;

  const ControlPanelWidget({
    super.key,
    required this.onClear,
    required this.onRecognize,
    required this.onSave,
    required this.onUndo,
    required this.onRedo,
    // required this.onDraw,
    // required this.onErase
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: onClear,
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: onRecognize,
            child: const Text('Recognize'),
          ),
          ElevatedButton(
            onPressed: onUndo,
            child: const Text('Undo'),
          ),
          ElevatedButton(
            onPressed: onRedo,
            child: const Text('Redo'),
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
}
