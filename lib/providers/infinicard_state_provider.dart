import 'package:flutter/material.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:hive/hive.dart';
import 'package:infinicard_v1/functions/buildUI/buildApp.dart';
import 'package:infinicard_v1/functions/compileXML/compileDrawing.dart';
import 'package:infinicard_v1/functions/helpers.dart';
import 'package:infinicard_v1/models/dollar_q.dart';
import 'package:infinicard_v1/models/draw_actions.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';
import 'package:infinicard_v1/models/draw_actions/clear_action.dart';
import 'package:infinicard_v1/models/draw_actions/delete_action.dart';
import 'package:infinicard_v1/models/draw_actions/erase_action.dart';
import 'package:infinicard_v1/models/draw_actions/line_action.dart';
import 'package:infinicard_v1/models/draw_actions/select_box_action.dart';
import 'package:infinicard_v1/models/draw_actions/stroke_action.dart';
import 'package:infinicard_v1/models/drawing.dart';
import 'package:infinicard_v1/objects/ICIconButton.dart';
import 'package:infinicard_v1/objects/ICTextButton.dart';
import 'package:infinicard_v1/widgets/overlay_widget.dart';

enum Tools { none, stroke, line, erase, box, select }

class InfinicardStateProvider extends ChangeNotifier {
  String source = "";
  infinicardApp icApp = infinicardApp("<root></root>");
  String currentPageName = "home";

  Widget widget = const Placeholder();

  List<String> activeViews = ["draw", "render"];
  String selectedView = "draw";

  Tools _toolSelected = Tools.stroke;

  Drawing? _drawing;
  DrawAction _pendingAction = NullAction();

  final List<DrawAction> _pastActions;
  final List<DrawAction> _futureActions;

  DrawAction _selectedAction = NullAction();

  final double width;
  final double height;

  bool styleVisibility = false;

  OverlayEntry entry = OverlayEntry(builder: (BuildContext context) {
    return SizedBox(width: 1, height: 0, child: const Text("HELLO"));
  });

  InfinicardStateProvider({required this.width, required this.height})
      : _pastActions = [],
        _futureActions = [];

  OverlayEntry getOverlay(BoxAction boxAction) {
    OverlayEntry entry = OverlayEntry(
        builder: (context) => Positioned(
            top: boxAction.rect.top,
            left: boxAction.rect.right - 180,
            child: OverlayWidget(boxAction)));
    return entry;
  }

  void setStartingPage(String newStartPage){
    icApp.startPageName = newStartPage;
    updateSource(compileDrawing(getActiveActions(), icApp));
    _invalidateAndNotify();

  }

  void updateActiveViews(String view, String action){
    if(action=="open"){
      if(!activeViews.contains(view)){
        activeViews.add(view);
      }
    } else if (action=="close"){
      if(activeViews.contains(view)){
        activeViews.remove(view);
      }
    }
    _invalidateAndNotify();
  }

  //Draw Methods
  Drawing get drawing {
    if (_drawing == null) {
      _createCachedDrawing();
    }
    return _drawing!;
  }

  set pendingAction(DrawAction action) {
    _pendingAction = action;
    _invalidateAndNotify();
  }

  DrawAction get pendingAction => _pendingAction;

  set selectedAction(DrawAction action) {
    _selectedAction = action;
    _invalidateAndNotify();
  }

  DrawAction get selectedAction => _selectedAction;

  set toolSelected(Tools aTool) {
    _toolSelected = aTool;
    _invalidateAndNotify();
  }

  Tools get toolSelected => _toolSelected;

  List<DrawAction> getActiveActions() {
    final futureIndexOfLastClearAction =
        _pastActions.lastIndexWhere((element) => element is ClearAction);
    if (futureIndexOfLastClearAction == -1) {
      return _pastActions;
    } else {
      final actions = _pastActions
          .getRange(futureIndexOfLastClearAction, _pastActions.length)
          .toList();
      return actions;
    }
  }

    List<BoxAction> getActiveBoxActions() {
    final futureIndexOfLastClearAction =
        _pastActions.lastIndexWhere((element) => element is ClearAction);
    if (futureIndexOfLastClearAction == -1) {
      return _pastActions.whereType<BoxAction>().toList();
    } else {
      final actions = _pastActions
          .getRange(futureIndexOfLastClearAction, _pastActions.length)
          .whereType<BoxAction>()
          .toList();
      return actions;
    }
  }

  _createCachedDrawing() {
    final futureIndexOfLastClearAction =
        _pastActions.lastIndexWhere((element) => element is ClearAction);
    if (futureIndexOfLastClearAction == -1) {
      // never been cleared
      _drawing = Drawing(_pastActions, width: width, height: height);
    } else {
      final actions = _pastActions
          .getRange(futureIndexOfLastClearAction, _pastActions.length)
          .toList();
      _drawing = Drawing(actions, width: width, height: height);
    }
  }

  _clearOverlay() {
    if (entry.mounted) {
      entry.remove();
    }
  }

  _invalidateAndNotify() {
    _drawing = null;
    notifyListeners();
  }

  add(DrawAction action) {
    _pastActions.add(action);
    _futureActions.clear();
    _invalidateAndNotify();
  }

  undo() {
    _clearOverlay();
    if (_pastActions.isEmpty) {
      return;
    } else {
      final action = _pastActions.removeLast();
      if (action is EraseAction) {
        for (DrawAction each in action.erased) {
          _pastActions.add(each);
        }
      } else if (action is DeleteAction) {
        if (action.deleted is BoxAction) {
          BoxAction deletedAction = action.deleted as BoxAction;
          List<DrawAction> strokes = deletedAction.strokes;
          for (DrawAction stroke in strokes) {
            _pastActions.add(stroke);
          }
          _pastActions.add(deletedAction);
        }
      }
      _futureActions.add(action);
    }
    updateSource(compileDrawing(getActiveActions(), icApp));
    _invalidateAndNotify();
  }

  redo() {
    _clearOverlay();
    if (_futureActions.isNotEmpty) {
      final action = _futureActions.removeLast();
      if (action is EraseAction) {
        for (DrawAction each in action.erased) {
          _pastActions.removeWhere((item) => item == each);
        }
      } else if (action is DeleteAction) {
        DrawAction deleted = action.deleted;
        if (deleted is BoxAction) {
          BoxAction deletedAction = action.deleted as BoxAction;
          List<DrawAction> strokes = deletedAction.strokes;
          for (DrawAction stroke in strokes) {
            _pastActions.removeWhere((item) => item == stroke);
          }
          _pastActions.removeWhere((item) => item == deletedAction);
        }
      }
      _pastActions.add(action);
      updateSource(compileDrawing(getActiveActions(), icApp));
      _invalidateAndNotify();
    }
  }

  clear() {
    add(ClearAction());
    _clearOverlay();
    updateSource(compileDrawing(getActiveActions(), icApp));
    _invalidateAndNotify();
  }

  delete(BoxAction boxAction){
    List<DrawAction> strokes = boxAction.strokes;
    for (DrawAction stroke in strokes) {
      _pastActions.removeWhere((item) => item == stroke);
    }
    _pastActions.removeWhere((item) => item == boxAction);
    _pastActions.add(DeleteAction(boxAction));
    // if(boxAction.elementName == "page"){
    //   for(BoxAction action in getActiveBoxActions()){
    //     if(action.pageName == boxAction.pageName){
    //       action.pageName = "home";
    //     }
    //   }
    // }
    if(boxAction.elementName == "page"){
      updateSource(compileDrawing(getActiveActions(), icApp));
    }
    if (entry.mounted) {
      entry.remove();
    }
    updateSource(compileDrawing(getActiveActions(), icApp));
    _invalidateAndNotify();
  }

  duplicate(BoxAction boxAction){
    double offset = 10.0;
    List<DrawAction> strokes = boxAction.strokes;
    debugPrint(boxAction.uniqueID.toString());
    BoxAction newBox = BoxAction(boxAction.point1, boxAction.point2);
    debugPrint(newBox.uniqueID.toString());
    newBox.rect = boxAction.rect.shift(Offset(offset, offset));
    // newBox.pageName = boxAction.pageName;
    newBox.elementName = boxAction.elementName;
    for (DrawAction stroke in strokes) {
      if (stroke is StrokeAction) {
        Path newPath = stroke.strokePath.shift(Offset(offset, offset));
        StrokeAction newStroke = StrokeAction(stroke.points);
        newStroke.strokePath = newPath;
        newStroke.box = newBox;
        newBox.strokes.add(newStroke);
        _pastActions.add(newStroke);
      }
    }
    newBox.element = boxAction.element.copyWith(newID:newBox.uniqueID);
    _pastActions.add(newBox);
    selectedAction = newBox;
    if (entry.mounted) {
      entry.remove();
    }
    updateSource(compileDrawing(getActiveActions(), icApp));
    _invalidateAndNotify();
  }

  updateDropdown(String value, BoxAction action){
    if(value != action.elementName){
      if(action.elementName == "page"){
        updateSource(compileDrawing(getActiveActions(), icApp));
      }
      action.elementName = value;
      action.element.id = action.uniqueID;
      action.element = initElement(action, getActiveActions(), icApp);
      styleVisibility = false;
    }
    updateSource(compileDrawing(getActiveActions(), icApp));
  }

    updateSelectPageAction(String target, BoxAction action){
      switch(action.elementName){
        case "iconButton":
            ICIconButton button = action.element as ICIconButton;
            if(target != button.action['target']){
              button.action['type'] = "page";
              button.action['target'] = target;
            }
          break;
        case "textButton":
            ICTextButton button = action.element as ICTextButton;
            if(target != button.action['target']){
              button.action['type'] = "page";
              button.action['target'] = target;
            }
          break;
      }
      updateSource(compileDrawing(getActiveActions(), icApp));
    }

  int intersect(double x1, double y1, double x2, double y2, double x3,
      double y3, double x4, double y4) {
    if ((x1 == x2 && y1 == y2) || (x3 == x4 && y3 == y4)) {
      return 0;
    }

    double denominator = ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1));

    if (denominator == 0) {
      return 0;
    }

    double ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator;
    double ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator;

    if (ua < 0 || ua > 1 || ub < 0 || ub > 1) {
      return 0;
    }

    return 1;
  }

  erase(EraseAction eraseAction) {
    _clearOverlay();
    List<DrawAction> erasableActions = [];
    final futureIndexOfLastClearAction =
        _pastActions.lastIndexWhere((element) => element is ClearAction);
    if (futureIndexOfLastClearAction == -1) {
      // never been cleared
      erasableActions = List.from(_pastActions);
    } else {
      erasableActions = List.from(_pastActions
          .getRange(futureIndexOfLastClearAction, _pastActions.length)
          .toList());
    }
    for (DrawAction action in erasableActions) {
      switch (action) {
        case ClearAction _:
          break;
        case NullAction _:
          break;
        case EraseAction _:
          break;
        case StrokeAction strokeAction:
          int intersecting = 0;

          for (int i = 0; i < eraseAction.points.length - 1; i++) {
            List<GesturePoint> eraseSegment = [
              eraseAction.points[i],
              eraseAction.points[i + 1]
            ];
            for (int j = 0; j < strokeAction.points.length - 1; j++) {
              List<GesturePoint> srokeSegment = [
                strokeAction.points[j],
                strokeAction.points[j + 1]
              ];
              intersecting += intersect(
                  eraseSegment[0].x,
                  eraseSegment[0].y,
                  eraseSegment[1].x,
                  eraseSegment[1].y,
                  srokeSegment[0].x,
                  srokeSegment[0].y,
                  srokeSegment[1].x,
                  srokeSegment[1].y);
            }
          }
          if (intersecting > 0) {
            eraseAction.erased.add(strokeAction);
            _pastActions.removeWhere((item) => item == strokeAction);
            if (strokeAction.box != null) {
              //find all other strokes in rhe box
              BoxAction currentBox = strokeAction.box!;
              currentBox.strokes.removeWhere((item) => item == strokeAction);
              if (currentBox.strokes.length == 0) {
                _pastActions.removeWhere((item) => item == currentBox);
              } else {
                List<Rect> elements = [];
                for (DrawAction stroke in currentBox.strokes) {
                  if (stroke is StrokeAction) {
                    elements.add(stroke.strokePath.getBounds());
                  } else if (stroke is LineAction) {
                    elements.add(stroke.linePath.getBounds());
                  }
                }
                currentBox.rect = combineRect(elements);
                updateSource(compileDrawing(getActiveActions(), icApp));
              }
            }
          }
          break;
        case LineAction lineAction:
          int intersecting = 0;

          for (int i = 0; i < eraseAction.points.length - 1; i++) {
            List<GesturePoint> eraseSegment = [
              eraseAction.points[i],
              eraseAction.points[i + 1]
            ];
            intersecting += intersect(
                eraseSegment[0].x,
                eraseSegment[0].y,
                eraseSegment[1].x,
                eraseSegment[1].y,
                lineAction.point1.x,
                lineAction.point1.y,
                lineAction.point2.x,
                lineAction.point2.y);
          }
          if (intersecting > 0) {
            eraseAction.erased.add(lineAction);
            _pastActions.removeWhere((item) => item == lineAction);
            if (lineAction.box != null) {
              _pastActions.removeWhere((item) => item == lineAction.box);
            }
          }
          break;
      }
    }
    if (eraseAction.erased.isNotEmpty) {
      _pastActions.add(eraseAction);
    }
  }

  Rect combineRect(List<Rect> elements) {
    Rect box = Rect.zero;
    if (elements.length > 1) {
      box = elements[0];
      for (int i = 1; i < elements.length; i++) {
        box = box.expandToInclude(elements[i]);
      }
      box = box.inflate(5);
    } else if (elements.length == 1) {
      box = elements[0].inflate(5);
    } else {
      box = Rect.zero;
    }
    return box;
  }

  click(SelectBoxAction selectAction) {
    List<DrawAction> clickableActions = getActiveActions();
    List<BoxAction> possibleSelections = [];

    selectedAction = NullAction();
    for (DrawAction action in clickableActions) {
      if (action is BoxAction) {
        Rect box = action.rect.inflate(5);
        if (box.contains(Offset(selectAction.point.x, selectAction.point.y))) {
          possibleSelections.add(action);
        }
      }
    }
    if (possibleSelections.length == 1) {
      selectedAction = possibleSelections[0];
      entry = getOverlay(possibleSelections[0]);
    } else if (possibleSelections.length > 1) {
      Size smallest = possibleSelections[0].rect.size;
      BoxAction current = possibleSelections[0];
      for (BoxAction each in possibleSelections) {
        Size boxSize = each.rect.size;
        if (boxSize <= smallest) {
          current = each;
          smallest = boxSize;
        }
      }
      selectedAction = current;
      entry = getOverlay(current);
    }
  }

  BoxAction? clickedBox(SelectBoxAction selectAction) {
    List<DrawAction> clickableActions = [];
    List<BoxAction> possibleSelections = [];
    final futureIndexOfLastClearAction =
        _pastActions.lastIndexWhere((element) => element is ClearAction);
    if (futureIndexOfLastClearAction == -1) {
      // never been cleared
      clickableActions = _pastActions;
    } else {
      clickableActions = _pastActions
          .getRange(futureIndexOfLastClearAction, _pastActions.length)
          .toList();
    }
    selectedAction = NullAction();
    for (DrawAction action in clickableActions) {
      if (action is BoxAction) {
        Rect box = action.rect;
        List<Rect> touchPoints = [
          Rect.fromCircle(center: box.bottomRight, radius: 5),
          Rect.fromCircle(center: box.topRight, radius: 5),
          Rect.fromCircle(center: box.bottomLeft, radius: 5),
          Rect.fromCircle(center: box.topLeft, radius: 5)
        ];
        if (box.contains(Offset(selectAction.point.x, selectAction.point.y))) {
          possibleSelections.add(action);
        } else {
          for (Rect point in touchPoints) {
            if (point
                .contains(Offset(selectAction.point.x, selectAction.point.y))) {
              possibleSelections.add(action);
            }
          }
        }
      }
    }
    if (possibleSelections.length == 1) {
      selectedAction = possibleSelections[0];
    } else if (possibleSelections.length > 1) {
      Size smallest = possibleSelections[0].rect.size;
      BoxAction current = possibleSelections[0];
      for (BoxAction each in possibleSelections) {
        Size boxSize = each.rect.size;
        if (boxSize <= smallest) {
          current = each;
          smallest = boxSize;
        }
      }
      selectedAction = current;
    }
    if (selectedAction is BoxAction) {
      BoxAction action = selectedAction as BoxAction;
      Offset point = Offset(selectAction.point.x, selectAction.point.y);
      Rect selectedBox = action.rect;
      if (Rect.fromCircle(center: selectedBox.topRight, radius: 5)
          .contains(point)) {
        selectAction.resize = true;
        selectAction.anchor = selectedBox.bottomLeft;
      } else if (Rect.fromCircle(center: selectedBox.topLeft, radius: 5)
          .contains(point)) {
        selectAction.resize = true;
        selectAction.anchor = selectedBox.bottomRight;
      } else if (Rect.fromCircle(center: selectedBox.bottomRight, radius: 5)
          .contains(point)) {
        selectAction.resize = true;
        selectAction.anchor = selectedBox.topLeft;
      } else if (Rect.fromCircle(center: selectedBox.bottomLeft, radius: 5)
          .contains(point)) {
        selectAction.resize = true;
        selectAction.anchor = selectedBox.topRight;
      } else {
        selectAction.resize = false;
      }
      return selectedAction as BoxAction;
    } else {
      return null;
    }
  }

  void translate(SelectBoxAction clickAction) {
    if (clickAction.selected != null &&
        clickAction.resize &&
        clickAction.anchor != null) {
      //Scaling
      BoxAction action = clickAction.selected as BoxAction;
      List<DrawAction> strokes = innerStrokes(action);
      Offset point = Offset(clickAction.point.x, clickAction.point.y);
      Rect oldBox = action.rect;
      action.rect = Rect.fromPoints(clickAction.anchor!, point);
      for (DrawAction stroke in strokes) {
        final Matrix4 matrix = Matrix4.identity();
        double scaleX = action.rect.width / oldBox.width;
        double scaleY = action.rect.height / oldBox.height;
        if (stroke is StrokeAction) {
          if (stroke.box == action) {
            matrix.translate(action.rect.center.dx, action.rect.center.dy);
            matrix.scale(scaleX, scaleY);
            matrix.translate(-oldBox.center.dx, -oldBox.center.dy);
            stroke.strokePath = stroke.strokePath.transform(matrix.storage);
          }
        } else if (stroke is LineAction) {
          if (stroke.box == action) {
            matrix.translate(action.rect.center.dx, action.rect.center.dy);
            matrix.scale(scaleX, scaleY);
            matrix.translate(-oldBox.center.dx, -oldBox.center.dy);
            stroke.linePath = stroke.linePath.transform(matrix.storage);
          }
        }
      }
    } else if (clickAction.selected != null) {
      //moving
      BoxAction action = clickAction.selected as BoxAction;
      List<DrawAction> strokes = innerStrokes(action);
      Offset point = Offset(clickAction.point.x, clickAction.point.y);
      Offset previous =
          Offset(clickAction.prevPoint.x, clickAction.prevPoint.y);
      Offset shift = point - previous;
      action.rect = action.rect.shift(shift);
      for (DrawAction stroke in strokes) {
        if (stroke is StrokeAction) {
          if (stroke.box == action) {
            stroke.strokePath = stroke.strokePath.shift(shift);
          }
        } else if (stroke is LineAction) {
          if (stroke.box == action) {
            stroke.linePath = stroke.linePath.shift(shift);
          }
        }
      }
    }
    updateSource(compileDrawing(getActiveActions(), icApp));
  }

  List<DrawAction> innerStrokes(BoxAction box) {
    List<DrawAction> actions = getActiveActions();
    List<DrawAction> elements = [];
    for (DrawAction action in actions) {
      if (action is StrokeAction) {
        if (contained(box, action)) {
          elements.add(action);
        }
      } else if (action is LineAction) {
        if (contained(box, action)) {
          elements.add(action);
        }
      }
    }
    return elements;
  }

  //Render Methods
  void updateSource(String newSource) {
    try {
      final infinicardApp newICApp = _compileInfinicardXML(newSource);
      final Widget newWidget = newICApp.toFlutter();
      icApp = newICApp;
      widget = newWidget;
      source = newSource;
      debugPrint("updatedSource");
      notifyListeners();
    } on Exception {
      // do something with this here
    }
  }

  String retrieveSource({bool verbose = false}) {
    final appXML = icApp.toXml(verbose: verbose);
    return appXML.toXmlString(pretty: true);
  }

  infinicardApp _compileInfinicardXML(source) {
    return infinicardApp(source);
  }
}
