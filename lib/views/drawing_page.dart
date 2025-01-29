import 'package:flutter/material.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/canvas_widget.dart';
import '../widgets/control_panel_widget.dart';

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
          content: const Text('Recognition completed'),
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

    return Consumer<InfinicardStateProvider>(
        builder: (context, infinicardProvider, unchangingChild) {
      
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ControlPanelWidget(
              onRecognize: () {
                widget.canvasKey.currentState?.recognizeGesture();
              },
            ),
            Expanded(
              child: CanvasWidget(
                key: widget.canvasKey,
                onRecognitionComplete: _onRecognitionComplete,
              ),
            ),
          ],
        ),
      );
    });
  }
}
