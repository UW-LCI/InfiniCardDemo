import 'draw_actions.dart';

class Drawing {
  final double width;
  final double height;

  final List<DrawAction> drawActions;

  Drawing(this.drawActions, {required this.width, required this.height});
}