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
import 'package:infinicard_v1/objects/ICPage.dart';
import 'package:infinicard_v1/objects/ICText.dart';
import 'package:infinicard_v1/objects/ICTextButton.dart';
import 'package:infinicard_v1/objects/ICTextStyle.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:provider/provider.dart';

class InteractionWidget extends StatefulWidget {
  BoxAction boxAction;

  InteractionWidget(this.boxAction, {super.key});

  @override
  State<InteractionWidget> createState() => _InteractionWidgetState();
}

class _InteractionWidgetState extends State<InteractionWidget> {
  

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<InfinicardStateProvider>(context, listen: false);

    List<DropdownMenuEntry> dropdownElements = [];
    for(ICPage page in provider.icApp.pages.values){
      dropdownElements.add(DropdownMenuEntry(value: page.pageName, label: page.pageName));
    }

    String? type;

    Map? action = {};
    switch(widget.boxAction.elementName){
      case "iconButton": 
          ICIconButton button = widget.boxAction.element as ICIconButton;
          action = button.action;
          if(action != null){
            if(action['type'] == "page"){
              String target = action['target'];
              if(provider.icApp.pages.keys.contains(target)){
                type = target;
              }
            }
          }
        break;
      case "textButton":
        break;
        
    }

    DropdownMenu menu = DropdownMenu(
        dropdownMenuEntries: dropdownElements,
        initialSelection: type,
        menuStyle: const MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white)),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                borderSide: BorderSide(color: Colors.grey.shade700))),
        onSelected: (value) {
          // provider.updateDropdown(value, widget.boxAction);
          provider.updateSelectPageAction(value, widget.boxAction);
          setState(() {
            type = value;
          });
        });

    Widget outputWidget = Padding(
        padding: EdgeInsets.only(top: 10),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade700),
                borderRadius: BorderRadius.all(Radius.circular(18))),
            width: 200,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(width: 200, height: 260, child: menu))));

    return outputWidget;
  }
}
