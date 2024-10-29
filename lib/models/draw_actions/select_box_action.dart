import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/dollar_q.dart';

import '../draw_actions.dart';

// Used to represent a line segment drawn by the user
class SelectBoxAction extends DrawAction {
  final GesturePoint point;

  SelectBoxAction(this.point);
}
