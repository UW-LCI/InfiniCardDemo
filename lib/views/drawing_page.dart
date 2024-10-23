import 'package:flutter/material.dart';
import '../widgets/canvas_widget.dart';
import '../widgets/control_panel_widget.dart';
import 'package:provider/provider.dart';
import '../providers/infinicard_state_provider.dart';

class DrawingPage extends StatefulWidget {
  final GlobalKey<CanvasWidgetState> canvasKey;
  const DrawingPage({super.key, required this.canvasKey});

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {

  void _onRecognitionComplete(String xml) {
    if (xml.isNotEmpty) {
      Provider.of<InfinicardStateProvider>(context, listen: false)
          .updateSource(xml);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recognition completed'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            right: 20,
            left: 20,
          ),
        ),
      );
    }
  }

  // Method to prompt the user for a gesture name
  Future<String?> _promptForGestureName(BuildContext context) async {
    String? gestureName;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Gesture'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Gesture Name',
            ),
            onChanged: (value) {
              gestureName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(gestureName);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drawing Recognition')),
      body: Column(
        children: [
          Expanded(
            child: CanvasWidget(
              key: widget.canvasKey,
              onRecognitionComplete: _onRecognitionComplete,
            ),
          ),
          ControlPanelWidget(
            onClear: () {
              widget.canvasKey.currentState?.clearCanvas();
            },
            onRecognize: () {
              widget.canvasKey.currentState?.recognizeGesture();
            },
            onSave: () async {
              String? name = await _promptForGestureName(context);
              if (name != null && name.trim().isNotEmpty) {
                widget.canvasKey.currentState?.saveGesture(name.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gesture "$name" saved successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gesture name cannot be empty')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}