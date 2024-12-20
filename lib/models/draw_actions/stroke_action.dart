import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/dollar_q.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';

import '../draw_actions.dart';


// This is used to represent a single continuous path drawn by the user, 
// for example, if they put their finger down, wiggled it around, and let go.
class StrokeAction extends DrawAction {
  final List<GesturePoint> points;
  Path strokePath = Path();

  StrokeAction(this.points);

  BoxAction? box;

  void addLine(GesturePoint point){
    strokePath.lineTo(point.x, point.y);
    // strokePath.moveTo(point.x, point.y);
}
  void initPath(GesturePoint point){
    strokePath.moveTo(point.x, point.y);
  }
}


