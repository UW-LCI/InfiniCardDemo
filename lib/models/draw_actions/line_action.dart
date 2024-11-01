import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/dollar_q.dart';

import '../draw_actions.dart';

// Used to represent a line segment drawn by the user
class LineAction extends DrawAction {
  final GesturePoint point1;
  final GesturePoint point2;

  Path linePath = Path();

  LineAction(this.point1, this.point2);

  void initPath(){
    linePath.moveTo(point1.x, point1.y);
    linePath.lineTo(point2.x, point2.y);
  }
}
