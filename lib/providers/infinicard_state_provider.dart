import 'package:flutter/material.dart';
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

enum Tools { none, stroke, line, erase, box, select }

class InfinicardStateProvider extends ChangeNotifier {
  String source = "";
  infinicardApp icApp = infinicardApp("<root></root>");
  Widget widget = const Placeholder();

  Tools _toolSelected = Tools.stroke;

  Drawing? _drawing;
  DrawAction _pendingAction = NullAction();

  final List<DrawAction> _pastActions;
  final List<DrawAction> _futureActions;

  DrawAction _selectedAction = NullAction();

  final double width;
  final double height;

  final List<DropdownMenuEntry> dropdownElements = [
    const DropdownMenuEntry(value: 'textButton', label: 'textButton'),
    const DropdownMenuEntry(value: 'text', label: 'text'),
    const DropdownMenuEntry(value: 'image', label: 'image'),
    const DropdownMenuEntry(value: 'row', label: 'row'),
    const DropdownMenuEntry(value: 'column', label: 'column'),
    const DropdownMenuEntry(value: 'iconButton', label: 'iconButton'),
    const DropdownMenuEntry(value: 'bar', label: 'bar'),
    const DropdownMenuEntry(value: 'icon', label: 'icon')
  ];
  DropdownMenu dropdown = DropdownMenu(dropdownMenuEntries: []);

  OverlayEntry entry = OverlayEntry(builder: (BuildContext context) {
    return SizedBox(width: 1, height: 0, child: const Text("HELLO"));
  });

  InfinicardStateProvider({required this.width, required this.height})
      : _pastActions = [],
        _futureActions = [];

  DropdownMenu initDropdown(List<DropdownMenuEntry> element, String? label) {
    return DropdownMenu(
      dropdownMenuEntries: element,
      initialSelection: label,
      menuStyle: const MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.white)),
      inputDecorationTheme:
          InputDecorationTheme(filled: true, fillColor: Colors.lightBlue[50]),
      onSelected: (value) {
        if (selectedAction is BoxAction) {
          BoxAction action = selectedAction as BoxAction;
          action.elementName = value;
          updateSource(compileDrawing(getActiveActions()));
        } else if (_pastActions.last is BoxAction) {
          BoxAction action = _pastActions.last as BoxAction;
          action.elementName = value;
          updateSource(compileDrawing(getActiveActions()));
        }
        _clearOverlay();
      },
    );
  }

  OverlayEntry getOverlay(DropdownMenu dropdown, BoxAction boxAction) {
    IconButton deleteBox = IconButton(
        onPressed: () {
          List<DrawAction> strokes = boxAction.strokes;
          for(DrawAction stroke in strokes){
            _pastActions.removeWhere((item)=>item==stroke);
          }
          _pastActions.removeWhere((item)=>item==boxAction);
          _pastActions.add(DeleteAction(boxAction));
          if(this.entry.mounted){
            this.entry.remove();
          }
          updateSource(compileDrawing(getActiveActions()));
          _invalidateAndNotify();
        },
        icon: const Icon(Icons.delete));
    OverlayEntry entry = OverlayEntry(
        builder: (context) => Positioned(
            top: boxAction.rect.top - 30,
            right: width - boxAction.rect.right - 30,
            child: SizedBox(width: 250, height: 100, child: Row(children:[dropdown, deleteBox]))));
    return entry;
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
      } else if(action is DeleteAction){
        if(action.deleted is BoxAction){
          BoxAction deletedAction = action.deleted as BoxAction;
          List<DrawAction> strokes = deletedAction.strokes;
          for(DrawAction stroke in strokes){
            _pastActions.add(stroke);
          }
          _pastActions.add(deletedAction);
        }
      }
      _futureActions.add(action);
    }
    updateSource(compileDrawing(getActiveActions()));
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
      } else if(action is DeleteAction){
        DrawAction deleted = action.deleted;
        if(deleted is BoxAction){
          BoxAction deletedAction = action.deleted as BoxAction;
          List<DrawAction> strokes = deletedAction.strokes;
          for(DrawAction stroke in strokes){
            _pastActions.removeWhere((item)=>item==stroke);
          }
          _pastActions.removeWhere((item)=>item==deletedAction);
        }
      }
      _pastActions.add(action);
      updateSource(compileDrawing(getActiveActions()));
      _invalidateAndNotify();
    }
  }

  clear() {
    add(ClearAction());
    _clearOverlay();
    updateSource(compileDrawing(getActiveActions()));
    _invalidateAndNotify();
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
                updateSource(compileDrawing(getActiveActions()));
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
      dropdown =
          initDropdown(dropdownElements, possibleSelections[0].elementName);
      entry = getOverlay(dropdown, possibleSelections[0]);
    } else if (possibleSelections.length > 1) {
      Size smallest = possibleSelections[0].rect.size;
      BoxAction current = possibleSelections[0];
      for (BoxAction each in possibleSelections) {
        Size boxSize = each.rect.size;
        if (boxSize < smallest) {
          current = each;
          smallest = boxSize;
        }
      }
      selectedAction = current;
      dropdown = initDropdown(dropdownElements, current.elementName);
      entry = getOverlay(dropdown, current);
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
        if (boxSize < smallest) {
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
    updateSource(compileDrawing(getActiveActions()));
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
