import 'package:flutter/material.dart';
import 'package:infinicard_v1/functions/buildApp.dart';
import 'package:infinicard_v1/models/dollar_q.dart';
import 'package:infinicard_v1/models/draw_actions.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';
import 'package:infinicard_v1/models/draw_actions/clear_action.dart';
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
    DropdownMenuEntry(value: 'textButton', label: 'textButton'),
    DropdownMenuEntry(value: 'text', label: 'text'),
    DropdownMenuEntry(value: 'image', label: 'image'),
    DropdownMenuEntry(value: 'row', label: 'row'),
    DropdownMenuEntry(value: 'column', label: 'column'),
    DropdownMenuEntry(value: 'iconButton', label: 'iconButton'),
    DropdownMenuEntry(value: 'bar', label: 'bar'),
    DropdownMenuEntry(value: 'icon', label: 'icon')
  ];
  DropdownMenu? dropdown;
  OverlayEntry entry = OverlayEntry(builder: (BuildContext context) {
    return Container(width: 0, height: 0, child: Text("HELLO"));
  });

  InfinicardStateProvider({required this.width, required this.height})
      : _pastActions = [],
        _futureActions = [];

  DropdownMenu initDropdown(List<DropdownMenuEntry> elements) {
    return DropdownMenu(dropdownMenuEntries: elements, menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(Colors.white)), inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.lightBlue[50]));
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
    if (_pastActions.isEmpty) {
      return;
    } else {
      final action = _pastActions.removeLast();
      if (action is EraseAction) {
        for (DrawAction each in action.erased) {
          _pastActions.add(each);
        }
      }
      _futureActions.add(action);
    }
    _invalidateAndNotify();
  }

  redo() {
    if (_futureActions.isNotEmpty) {
      final action = _futureActions.removeLast();
      if (action is EraseAction) {
        for (DrawAction each in action.erased) {
          _pastActions.removeWhere((item) => item == each);
        }
      }
      _pastActions.add(action);
      _invalidateAndNotify();
    }
  }

  clear() {
    add(ClearAction());
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
          }
          break;
      }
    }
    if (eraseAction.erased.isNotEmpty) {
      _pastActions.add(eraseAction);
    }
  }

  click(SelectBoxAction selectAction) {
    dropdown ??= initDropdown(dropdownElements);
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
        Rect box = Rect.fromPoints(Offset(action.point1.x, action.point1.y),
            Offset(action.point2.x, action.point2.y));
        action.rect = box;
        if (box.contains(Offset(selectAction.point.x, selectAction.point.y))) {
          possibleSelections.add(action);
        }
      }
    }
    if (possibleSelections.length == 1) {
      selectedAction = possibleSelections[0];
      entry = OverlayEntry(
          builder: (context) => Positioned(
              top: selectAction.point.y,
              left: selectAction.point.x,
              child: Container(width: 200, height: 100, child: dropdown)));
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
      // entry = OverlayEntry(builder: (BuildContext context) {
      //   return Text(current.rect.width.toString());}
      entry = OverlayEntry(
          builder: (context) => Positioned(
              top: selectAction.point.y,
              left: selectAction.point.x,
              child: Container(width: 200, height: 100, child: dropdown)));
    }
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
