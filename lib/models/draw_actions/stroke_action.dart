import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/dollar_q.dart';

import '../draw_actions.dart';


// This is used to represent a single continuous path drawn by the user, 
// for example, if they put their finger down, wiggled it around, and let go.
class StrokeAction extends DrawAction {
  final List<GesturePoint> points;

  StrokeAction(this.points);
}