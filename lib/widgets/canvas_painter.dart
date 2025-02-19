import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/canvasTheme.dart';
import 'package:infinicard_v1/models/dollar_q.dart';
import 'package:infinicard_v1/models/draw_actions.dart';
import 'package:infinicard_v1/models/draw_actions/clear_action.dart';
import 'package:infinicard_v1/models/draw_actions/delete_action.dart';
import 'package:infinicard_v1/models/draw_actions/erase_action.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';
import 'package:infinicard_v1/models/draw_actions/line_action.dart';
import 'package:infinicard_v1/models/draw_actions/select_box_action.dart';
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

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    clearPaint.style = PaintingStyle.stroke;
    canvas.drawRect(rect, clearPaint);

    for (final action in _provider.drawing.drawActions){
      _paintAction(canvas, action, size);
    }

    final actionInProgress = _provider.pendingAction;
    _paintAction(canvas, actionInProgress, size);

  }

  void _paintAction(Canvas canvas, DrawAction action, Size size){
    final Rect rect = Offset.zero & size;
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    clearPaint.style = PaintingStyle.stroke;

    switch (action) {
        case NullAction _:
          break;
        case SelectBoxAction _:
          break;
        case DeleteAction _:
          break;
        case ClearAction _:
          canvas.drawRect(rect, clearPaint);
          break;
        case StrokeAction strokeAction:
          final paint = Paint()
            ..color = const ui.Color.fromARGB(255, 0, 0, 0)
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 5.0;
          paint.style = PaintingStyle.stroke;
          Path path = strokeAction.strokePath;
          canvas.drawPath(path, paint);
          break;
        case LineAction lineAction:
          final paint = Paint()
            ..color = const ui.Color.fromARGB(255, 0, 0, 0)
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 5.0;
          paint.style = PaintingStyle.stroke;
          Path path = lineAction.linePath;
          canvas.drawPath(path, paint);
          break;
        case BoxAction boxAction:
          Color boxColor = Colors.blue;
          if(boxAction == _provider.selectedAction){
            boxColor = Colors.green;
          }
          final paint = Paint()
          ..strokeWidth = 2
          ..color = boxColor;
          paint.style = PaintingStyle.stroke;
          final paint2 = Paint()
          ..strokeWidth = 2
          ..color = boxColor;
          paint2.style = PaintingStyle.fill;
          Rect box = action.rect;
          Path boxPath = Path();
          Path touchPoints = Path();

          touchPoints.addOval(Rect.fromCircle(center:box.topRight,radius: 5));
          touchPoints.addOval(Rect.fromCircle(center:box.topLeft,radius: 5));
          touchPoints.addOval(Rect.fromCircle(center:box.bottomRight,radius: 5));
          touchPoints.addOval(Rect.fromCircle(center:box.bottomLeft,radius: 5));

          boxPath.addRect(box);
          
          canvas.drawPath(boxPath, paint);
          canvas.drawPath(touchPoints, paint2);
          break;
        case EraseAction eraseAction:
          final paint = Paint()
            ..color = CanvasTheme.backgroundColor
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 5.0;
          paint.style = PaintingStyle.stroke;
          List<GesturePoint> strokes = eraseAction.points;
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
        default:
          throw UnimplementedError('Action not implemented: $action'); 
      }
  }
  
  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return oldDelegate._drawing != _drawing;
  }


}