import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/dollar_q.dart';

import '../draw_actions.dart';

// Used to represent a line segment drawn by the user
class BoxAction extends DrawAction {
  final GesturePoint point1;
  final GesturePoint point2;

  Rect rect = Rect.fromPoints(Offset.zero, Offset.zero);

  BoxAction(this.point1, this.point2);
}
