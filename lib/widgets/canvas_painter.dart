import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/dollar_q.dart';
import 'package:infinicard_v1/models/draw_actions.dart';
import 'package:infinicard_v1/models/draw_actions/clear_action.dart';
import 'package:infinicard_v1/models/draw_actions/line_action.dart';
import 'package:infinicard_v1/models/draw_actions/stroke_action.dart';
import 'package:infinicard_v1/models/drawing.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';

class CanvasPainter extends CustomPainter {
  // final List<List<GesturePoint>> strokes;

  final Drawing _drawing;
  final InfinicardStateProvider _provider;

  CanvasPainter(InfinicardStateProvider provider) : _drawing = provider.drawing, _provider = provider;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.clipRect(rect); // make sure we don't scribble outside the lines.

    final erasePaint = Paint()..blendMode = BlendMode.clear;
    erasePaint.style = PaintingStyle.stroke;
    canvas.drawRect(rect, erasePaint);

    for (final action in _provider.drawing.drawActions){
      _paintAction(canvas, action, size);
    }

    final actionInProgress = _provider.pendingAction;
    _paintAction(canvas, actionInProgress, size);
  }

  void _paintAction(Canvas canvas, DrawAction action, Size size){
    final Rect rect = Offset.zero & size;
    final erasePaint = Paint()..blendMode = BlendMode.clear;
    erasePaint.style = PaintingStyle.stroke;

    switch (action) {
        case NullAction _:
          break;
        case ClearAction _:
          canvas.drawRect(rect, erasePaint);
          break;
        case StrokeAction strokeAction:
          final paint = Paint()
            ..color = const ui.Color.fromARGB(255, 0, 0, 0)
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 5.0;
          paint.style = PaintingStyle.stroke;
          List<GesturePoint> strokes = strokeAction.points;
          var path = Path();
          path.moveTo(strokes[0].x, strokes[0].y);
          if(strokes.length > 1){
            for (int i = 1; i < strokes.length; i++) {   
              path.lineTo(strokes[i].x, strokes[i].y);
            }
            canvas.drawPath(path, paint);
          } else if (strokes.length == 1) {
            canvas.drawPoints(ui.PointMode.points, [Offset(strokes[0].x, strokes[0].y)], paint);
          }
          break;
        case LineAction lineAction:
          final paint = Paint()
          ..strokeWidth = 2;
          canvas.drawLine(Offset(lineAction.point1.x, lineAction.point1.y), 
            Offset(lineAction.point2.x, lineAction.point2.y), paint);
          break;
        default:
          throw UnimplementedError('Action not implemented: $action'); 
      }
  }
  
  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return oldDelegate._drawing != _drawing;
  }
}