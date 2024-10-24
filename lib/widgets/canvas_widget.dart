import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:infinicard_v1/functions/buildApp.dart';
import 'package:infinicard_v1/models/draw_actions/erase_action.dart';
import 'package:infinicard_v1/models/draw_actions/line_action.dart';
import 'package:infinicard_v1/models/draw_actions/null_action.dart';
import 'package:infinicard_v1/models/draw_actions/stroke_action.dart';
import 'package:infinicard_v1/models/multi_stroke_write.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:provider/provider.dart';
import '../models/multi_stroke_parser.dart';
import '../models/dollar_q.dart';
import '../widgets/canvas_painter.dart';

class CanvasWidget extends StatefulWidget {
  final Function(String) onRecognitionComplete;

  const CanvasWidget({super.key, required this.onRecognitionComplete});

  @override
  CanvasWidgetState createState() => CanvasWidgetState();
}

class CanvasWidgetState extends State<CanvasWidget> {
  List<List<GesturePoint>> _strokes = [];
  // List<List<GesturePoint>> _undoQueue = [];
  // List<List<GesturePoint>> _clearedStrokes = [];
  // StrokeAction _currentStroke;
  late DollarQ _dollarQ;
  // String mode = "draw";

  @override
  void initState() {
    super.initState();
    _dollarQ = DollarQ();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      var templates = await MultiStrokeParser.loadStrokePatternsLocal();
      _dollarQ.templates = templates;
      print("Loaded ${templates.length} templates");
    } catch (e) {
      print("Error loading templates: $e");
    }
  }

  GesturePoint _createPoint(PointerEvent event) {
    double? pressure;
    if (event.kind == PointerDeviceKind.stylus) {
      pressure = (event.pressure * 255).round().toDouble();
    }
    return GesturePoint(event.localPosition.dx, event.localPosition.dy,
        event.timeStamp.inMilliseconds.toDouble(), pressure);
  }

  void _handlePointerDown(
      PointerDownEvent event, InfinicardStateProvider infinicardProvider) {
    switch (infinicardProvider.toolSelected) {
      case Tools.none:
        infinicardProvider.pendingAction = NullAction();
        break;
      case Tools.stroke:
        StrokeAction action = StrokeAction([_createPoint(event)]);
        action.initPath(_createPoint(event));
        infinicardProvider.pendingAction = action;
        break;
      case Tools.line:
        infinicardProvider.pendingAction = LineAction(
          _createPoint(event),
          _createPoint(event,
          )
        );
        break;
      case Tools.erase:
        EraseAction action = EraseAction([_createPoint(event)]);
        action.initPath(_createPoint(event));
        infinicardProvider.pendingAction = action;
        break;
    }
  }

  void _handlePointerMove(
      PointerMoveEvent event, InfinicardStateProvider infinicardProvider) {
    // setState(() {
    //   _currentStroke.add(_createPoint(event));
    //   _strokes[_strokes.length - 1] = List.from(_currentStroke);
    // });

    switch (infinicardProvider.toolSelected) {
      case Tools.none:
        break;
      case Tools.stroke:
        final pendingAction = infinicardProvider.pendingAction as StrokeAction;
        pendingAction.points.add(_createPoint(event));
        pendingAction.addLine(_createPoint(event));
        infinicardProvider.pendingAction = pendingAction;
        break;
      case Tools.line:
        final pendingAction = infinicardProvider.pendingAction as LineAction;
        infinicardProvider.pendingAction = LineAction(
          pendingAction.point1,
          _createPoint(event)
        );
      case Tools.erase:
        final pendingAction = infinicardProvider.pendingAction as EraseAction;
        pendingAction.points.add(_createPoint(event));
        pendingAction.addLine(_createPoint(event));
        infinicardProvider.pendingAction = pendingAction;
        break;
    }
  }

  void _handlePointerUp(
      PointerUpEvent event, InfinicardStateProvider infinicardProvider) {
    infinicardProvider.add(infinicardProvider.pendingAction);
    if(infinicardProvider.toolSelected == Tools.erase){
      infinicardProvider.erase(infinicardProvider.pendingAction as EraseAction);
    }
    infinicardProvider.pendingAction = NullAction();
  }

  Future<String> _recognizeGesture() async {
    var flattenedStrokes = _strokes.expand((stroke) => stroke).toList();
    var candidate = MultiStrokePath(flattenedStrokes);
    var result = _dollarQ.recognize(candidate);

    if (result.isNotEmpty) {
      // var score = result['score'] as double;
      var templateIndex = result['templateIndex'] as int;
      var templateName = _dollarQ.templates[templateIndex].name;
      if (templateName == 'button') {
        templateName = 'textButton';
      }
      widget.onRecognitionComplete('Recognized: $templateName');
      return templateName;
    } else {
      widget.onRecognitionComplete('No match found');
      return 'Unknown';
    }
  }

  Future<void> _saveGesture(String name) async {
    var flattenedStrokes = _strokes.expand((stroke) => stroke).toList();
    var multistroke = MultiStrokePath(flattenedStrokes, name);
    var writer = MultiStrokeWrite();
    writer.startGesture(name: name, subject: "01", multistroke: multistroke);

    try {
      await writer.saveToDirectory(name, name);
      print("Gesture saved successfully");
      // Reload templates after saving
      await _loadTemplates();
    } catch (e) {
      print("Error saving gesture: $e");
    }
  }
  //End of DOLLAR Q recognition

  // void _clear() {
  //   widget.onRecognitionComplete('');
  // }

  String recognizeGesture() {
    // String result = await _recognizeGesture();
    String result = '';
    _recognizeGesture().then((String value) {
      setState(() {
        print("Value: $value");
        result = value.toString();
      });
    });
    return result;
  }

  // Future<void> saveGesture(String name) async {
  //   await _saveGesture(name);
  // }
// {root: {ui: {image: {path: }, text: {data: Text}, textbutton: }}}

  // Future<String> -> XML
  Map<dynamic, dynamic> stringToDictionary() {
    Map<String, dynamic> dictionary = {
      "root": {"ui": {}}
    };
    String gesture = recognizeGesture();
    dictionary["root"]["ui"] = {gesture: {}};
    return dictionary;
  }

  String dictionaryToXML(Map<dynamic, dynamic> dictionary) {
    try {
      String xml = "";
      dictionary.forEach((key, value) {
        xml += "<$key>";
        if (value is Map) {
          xml += dictionaryToXML(value);
        } else {
          xml += value.toString();
        }
        xml += "</$key>";
      });
      return xml;
    } catch (e) {
      debugPrint("XML generation error: $e");
      return "<root><ui></ui></root>";
    }
  }

  // void clear() {
  //   setState(() {
  //     _strokes.clear();
  //   });
  //   widget.onRecognitionComplete('');
  // }

  // Future<String> recognize() async {
  //   String result = await _recognizeGesture();
  //   if (result.isNotEmpty) {
  //     Map<dynamic, dynamic> dictionary = {"root": {"ui": {}}};
  //     dictionary["root"]["ui"] = {result: {}};
  //     String xml = dictionaryToXML(dictionary);
  //     return xml;
  //   }
  //   return "<root><ui></ui></root>";
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<InfinicardStateProvider>(
        builder: (context, infinicardProvider, unchangingChild) {
      return Listener(
        onPointerDown: (event) => _handlePointerDown(event, infinicardProvider),
        onPointerMove: (event) => _handlePointerMove(event, infinicardProvider),
        onPointerUp: (event) => _handlePointerUp(event, infinicardProvider),
        child: CustomPaint(
          foregroundPainter: CanvasPainter(infinicardProvider),
          child: Scaffold(body: Container(
            width: infinicardProvider.width,
            height: infinicardProvider.width,
            color: Colors.transparent,
            child:unchangingChild
          ),
          ),
        ),
      );
    });
  }
}
