import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:infinicard_v1/functions/buildUI/buildApp.dart';
import 'package:infinicard_v1/functions/helpers.dart';
import 'package:infinicard_v1/models/draw_actions.dart';
import 'package:infinicard_v1/models/draw_actions/erase_action.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';
import 'package:infinicard_v1/models/draw_actions/line_action.dart';
import 'package:infinicard_v1/models/draw_actions/null_action.dart';
import 'package:infinicard_v1/models/draw_actions/select_box_action.dart';
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
      case Tools.select:
        SelectBoxAction action = SelectBoxAction(_createPoint(event));
        infinicardProvider.pendingAction = action;
        break;
      case Tools.stroke:
        StrokeAction action = StrokeAction([_createPoint(event)]);
        action.initPath(_createPoint(event));
        infinicardProvider.pendingAction = action;
        break;
      case Tools.line:
        LineAction action = LineAction(_createPoint(event),_createPoint(event));
        action.initPath();
        infinicardProvider.pendingAction = action;
        break;
      case Tools.erase:
        EraseAction action = EraseAction([_createPoint(event)]);
        action.initPath(_createPoint(event));
        infinicardProvider.pendingAction = action;
        break;
      case Tools.box:
        infinicardProvider.pendingAction = BoxAction(
          _createPoint(event),
          _createPoint(event,
          )
        );
        OverlayEntry entry = infinicardProvider.entry;
        if(entry.mounted){
          entry.remove();
        }
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
      case Tools.select:
        SelectBoxAction action = SelectBoxAction(_createPoint(event));
        infinicardProvider.pendingAction = action;
        break;
      case Tools.stroke:
        final pendingAction = infinicardProvider.pendingAction as StrokeAction;
        pendingAction.points.add(_createPoint(event));
        pendingAction.addLine(_createPoint(event));
        infinicardProvider.pendingAction = pendingAction;
        break;
      case Tools.line:
        final pendingAction = infinicardProvider.pendingAction as LineAction;
        LineAction action = LineAction(pendingAction.point1,_createPoint(event));
        action.initPath();
        infinicardProvider.pendingAction = action;
      case Tools.erase:
        final pendingAction = infinicardProvider.pendingAction as EraseAction;
        pendingAction.points.add(_createPoint(event));
        pendingAction.addLine(_createPoint(event));
        infinicardProvider.pendingAction = pendingAction;
        break;
      case Tools.box:
        final pendingAction = infinicardProvider.pendingAction as BoxAction;
        BoxAction action = BoxAction(pendingAction.point1,_createPoint(event));
        Rect box = Rect.fromPoints(Offset(action.point1.x, action.point1.y),Offset(action.point2.x, action.point2.y));
        action.rect = box;
        infinicardProvider.pendingAction = action;
        
        break;
    }
  }

  void _handlePointerUp(
      PointerUpEvent event, InfinicardStateProvider infinicardProvider, BuildContext context) {
    if(infinicardProvider.toolSelected == Tools.select){
      OverlayEntry entry = infinicardProvider.entry;
      if(entry.mounted){
        entry.remove();
      }
      infinicardProvider.click(infinicardProvider.pendingAction as SelectBoxAction);
      OverlayEntry newEntry = infinicardProvider.entry;
      if(entry != newEntry){
        Overlay.of(context).insert(newEntry);
      }
    }
    else if(infinicardProvider.toolSelected == Tools.box){
        BoxAction action = infinicardProvider.pendingAction as BoxAction;
        Rect box = Rect.fromPoints(Offset(action.point1.x, action.point1.y),Offset(action.point2.x, action.point2.y));
        action.rect = box;

        List<Rect> containedStrokes = strokesWithin(action, infinicardProvider);
        List<Rect> containedBoxes = boxesWithin(action, infinicardProvider);
        Rect boundingBox = combineRect(containedBoxes, action);
        Rect newBox = combineRect(containedStrokes, action);

        if(boundingBox.size > newBox.size && containedBoxes.isNotEmpty){
          action.rect = boundingBox.inflate(5);
        } else {
          action.rect = newBox;
        }
        
        infinicardProvider.dropdown = infinicardProvider.initDropdown(infinicardProvider.dropdownElements, null);
        OverlayEntry entry = infinicardProvider.entry;
        if(entry.mounted){
          entry.remove();
        }
        infinicardProvider.entry = OverlayEntry(
          builder: (context) => Positioned(
              top: action.point2.y,
              left: action.point2.x,
              child: Container(width: 200, height: 100, child: infinicardProvider.dropdown)));
        OverlayEntry newEntry = infinicardProvider.entry;
        if(entry != newEntry){
          Overlay.of(context).insert(newEntry);
        }
        infinicardProvider.add(infinicardProvider.pendingAction);
        
    }
    else {
      infinicardProvider.add(infinicardProvider.pendingAction);
      if(infinicardProvider.toolSelected == Tools.erase){
        infinicardProvider.erase(infinicardProvider.pendingAction as EraseAction);
      }
      
    }
    
    infinicardProvider.pendingAction = NullAction();
  }

  List<Rect> strokesWithin(BoxAction box, InfinicardStateProvider infinicardProvider){
    List<Rect> elements = [];
    for(DrawAction action in infinicardProvider.drawing.drawActions){
      if(action is StrokeAction){
        if(contained(box, action)){
          elements.add(action.strokePath.getBounds());
        }
      } else if(action is LineAction){
        if(contained(box, action)){
          elements.add(action.linePath.getBounds());
        }
      }
    }
    return elements;
  }

  List<Rect> boxesWithin(BoxAction box, InfinicardStateProvider infinicardProvider){
    List<Rect> elements = [];
    for(DrawAction action in infinicardProvider.drawing.drawActions){
      if(action is BoxAction){
        if(contained(box, action)){
          elements.add(action.rect);
        }
      } 
    }
    return elements;
  }

  Rect combineRect(List<Rect> elements, BoxAction action){
    Rect box = action.rect;
    if(elements.length>1){
      box = elements[0];
      for(int i=1; i<elements.length; i++){
        box = box.expandToInclude(elements[i]);
      }
      box = box.inflate(5);
    } else if(elements.length==1){
      box = elements[0].inflate(5);
    } else {
      box = action.rect;
    }
    action.rect = box;
    return box;
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
        onPointerUp: (event) => _handlePointerUp(event, infinicardProvider, context),
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
