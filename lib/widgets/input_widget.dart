import 'package:flutter/material.dart';
import 'package:infinicard_v1/fonts.dart';
import 'package:infinicard_v1/functions/compileXML/compileDrawing.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinicard_v1/objects/ICButtonStyle.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:infinicard_v1/objects/ICIcon.dart';
import 'package:infinicard_v1/objects/ICIconButton.dart';
import 'package:infinicard_v1/objects/ICText.dart';
import 'package:infinicard_v1/objects/ICTextButton.dart';
import 'package:infinicard_v1/objects/ICTextStyle.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:provider/provider.dart';

class InputWidget extends StatefulWidget {
  BoxAction boxAction;

  InputWidget(this.boxAction, {super.key});

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {    
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<InfinicardStateProvider>(context, listen: false);

    switch (widget.boxAction.elementName) {
      case "text":
        ICText text = widget.boxAction.element as ICText;
        _textController.text = text.data;
        break;
      case "textButton":
        ICTextButton textButton = widget.boxAction.element as ICTextButton;
        _textController.text = textButton.child.data;
        break;
    }

    void updateText(String s){
      switch(widget.boxAction.elementName){
        case "text":
          ICText text = widget.boxAction.element as ICText;
          text.data = s;
          provider.updateSource(compileDrawing(provider.getActiveActions()));
          break;
        case "textButton":
          ICTextButton textButton = widget.boxAction.element as ICTextButton;
          textButton.child.data = s;
          provider.updateSource(compileDrawing(provider.getActiveActions()));
          break;
      }
    }

    TextFormField textInput = TextFormField(
      controller: _textController,
      initialValue: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(border: InputBorder.none),
      minLines: 10,
      maxLines: null,
      onChanged: (s) => updateText(s),
    );

    return Padding(padding:EdgeInsets.only(top:10), child:Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade700),
            borderRadius: BorderRadius.all(Radius.circular(18))),
        width: 200,
        child: Padding(padding:EdgeInsets.all(10), child:SizedBox(width:200, height:260, child:textInput))));
  }
}
