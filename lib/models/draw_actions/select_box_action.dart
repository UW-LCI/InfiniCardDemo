import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/dollar_q.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';

import '../draw_actions.dart';

class SelectBoxAction extends DrawAction {
  GesturePoint point;
  GesturePoint startPoint;
  GesturePoint prevPoint;

  BoxAction? selected;

  //designates an element as having been clicked in the resize locations
  bool resize = false;
  Offset? anchor;

  SelectBoxAction(this.startPoint, this.point, this.prevPoint);
}
