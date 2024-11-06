import 'package:infinicard_v1/models/draw_actions.dart';

class DeleteAction extends DrawAction{
  DrawAction deleted;

  DeleteAction(this.deleted);
}