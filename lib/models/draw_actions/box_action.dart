import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/dollar_q.dart';
import 'package:infinicard_v1/objects/ICObject.dart';
import 'package:infinicard_v1/objects/ICText.dart';
import 'package:infinicard_v1/objects/ICUndefined.dart';

import '../draw_actions.dart';

// Used to represent a bounding box drawn by the user
class BoxAction extends DrawAction {
  final GesturePoint point1;
  final GesturePoint point2;

  int uniqueID = UniqueKey().hashCode;
  bool active = true;

  String elementName = "";

  List<DrawAction> strokes = [];

  Rect rect = Rect.fromPoints(Offset.zero, Offset.zero);

  ICObject element = ICUndefined();
  // String pageName = "home";


  BoxAction(this.point1, this.point2);

}
