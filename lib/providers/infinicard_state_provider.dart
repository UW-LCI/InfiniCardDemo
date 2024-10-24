
import 'package:flutter/material.dart';
import 'package:infinicard_v1/functions/buildApp.dart';
import 'package:infinicard_v1/models/draw_actions.dart';
import 'package:infinicard_v1/models/draw_actions/clear_action.dart';
import 'package:infinicard_v1/models/draw_actions/line_action.dart';
import 'package:infinicard_v1/models/draw_actions/stroke_action.dart';
import 'package:infinicard_v1/models/drawing.dart';
enum Tools { none, stroke, line, erase }
class InfinicardStateProvider extends ChangeNotifier{

  String source = "";
  infinicardApp icApp = infinicardApp("<root></root>");
  Widget widget = const Placeholder();

  Tools _toolSelected = Tools.stroke;

  Drawing? _drawing;
  DrawAction _pendingAction = NullAction();

  final List<DrawAction> _pastActions;
  final List<DrawAction> _futureActions;

  final double width;
  final double height;

  InfinicardStateProvider({required this.width, required this.height})
    : _pastActions = [],
      _futureActions = [];


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

  set toolSelected(Tools aTool) {
    _toolSelected = aTool;
    _invalidateAndNotify();
  }

  Tools get toolSelected => _toolSelected;

  _createCachedDrawing() {
    final futureIndexOfLastClearAction = _pastActions.lastIndexWhere((element) => element is ClearAction);
    if (futureIndexOfLastClearAction == -1){ // never been cleared
      _drawing = Drawing(_pastActions, width: width, height: height);
    } else {
      final actions = _pastActions.getRange(futureIndexOfLastClearAction, _pastActions.length).toList();
      _drawing = Drawing(actions, width: width, height: height);
    }
  }

  _invalidateAndNotify() {
    _drawing = null;
    notifyListeners();
  }

  add(DrawAction action){
    _pastActions.add(action);
    _futureActions.clear();
    _invalidateAndNotify();
  }

  undo(){
    if (_pastActions.isEmpty){
      return;
    } else {
      final action = _pastActions.removeLast();
      _futureActions.add(action);
    }
    _invalidateAndNotify();
  }

  redo(){
    if (_futureActions.isNotEmpty){
      final action = _futureActions.removeLast();
      _pastActions.add(action);
      _invalidateAndNotify();
    }
  }

  clear(){
    add(ClearAction());
    _invalidateAndNotify();
  }

  erase(DrawAction eraseAction) {
    List<DrawAction> erasableActions = [];
    final futureIndexOfLastClearAction = _pastActions.lastIndexWhere((element) => element is ClearAction);
    if (futureIndexOfLastClearAction == -1){ // never been cleared
      erasableActions = _pastActions;
    } else {
      final erasableActions = _pastActions.getRange(futureIndexOfLastClearAction, _pastActions.length).toList();
    }

    for (DrawAction action in erasableActions){
      switch(action){
        case ClearAction _:
          debugPrint("clear");
          break;
        case NullAction _:
          debugPrint("null");
          break;
        case StrokeAction _:
          debugPrint("stroke");
          break;
        case LineAction _:
          debugPrint("line");
          break;
      }
    }

  }

  //Render Methods
  void updateSource(String newSource){
    try{
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

  String retrieveSource({bool verbose = false}){
    final appXML = icApp.toXml(verbose: verbose);
    return appXML.toXmlString(pretty:true);
  }

  infinicardApp _compileInfinicardXML(source){
    return infinicardApp(source);
  }



}

