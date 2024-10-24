import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/dollar_q.dart';

import '../draw_actions.dart';


// This is used to represent a single continuous path drawn by the user, 
// for example, if they put their finger down, wiggled it around, and let go.
class EraseAction extends DrawAction {
  final List<GesturePoint> points;

  Path strokePath = Path();

  EraseAction(this.points);

  List<DrawAction> erased = []; 

  void addLine(GesturePoint point){
    strokePath.lineTo(point.x, point.y);
  }
  void initPath(GesturePoint point){
    strokePath.moveTo(point.x, point.y);
  }

}