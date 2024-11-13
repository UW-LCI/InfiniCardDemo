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
import 'package:infinicard_v1/objects/ICText.dart';
import 'package:infinicard_v1/objects/ICTextButton.dart';
import 'package:infinicard_v1/objects/ICTextStyle.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:provider/provider.dart';

class StyleWidget extends StatefulWidget {
  BoxAction boxAction;

  StyleWidget(this.boxAction, {super.key});

  @override
  State<StyleWidget> createState() => _StyleWidgetState();
}

class _StyleWidgetState extends State<StyleWidget> {    
  Color pickerColor = Colors.white;
  Color currentColor = Colors.blue;

  //   final List<DropdownMenuEntry> fonts = [
  //   DropdownMenuEntry(value: "Abril Fatface", label: "Abril Fatface"),
  //   DropdownMenuEntry(value: "Alegreya Sans", label: "Alegreya Sans"),
  //   DropdownMenuEntry(value: "Architects Daughter", label: "Architects Daughter"),
  //   DropdownMenuEntry(value: "Archivo", label: "Archivo"),
  // ];

  String selectedFont = "lato";

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<InfinicardStateProvider>(context, listen: false);

    List<Tab> tabs = [];
    List<Widget> tabViews = [];

    void changeColor(Color color) {
      setState(() => pickerColor = color);
      switch(widget.boxAction.elementName){
        case "text":
          ICText text = widget.boxAction.element as ICText;
          ICTextStyle style = ICTextStyle();
          style.textColor = ICColor("0xff${colorToHex(color,enableAlpha:false)}");
          text.setStyle(style);
          provider.updateSource(compileDrawing(provider.getActiveActions()));
          break;
        case "icon":
          ICIcon icon = widget.boxAction.element as ICIcon;
          icon.setColor(ICColor("0xff${colorToHex(color,enableAlpha:false)}"));
          provider.updateSource(compileDrawing(provider.getActiveActions()));
          break;
        case "textButton":
          ICTextButton textButton = widget.boxAction.element as ICTextButton;
          ICText text = textButton.child;
          ICTextStyle style = ICTextStyle();
          style.textColor = ICColor("0xff${colorToHex(color,enableAlpha:false)}");
          text.setStyle(style);
          textButton.child = text;
          provider.updateSource(compileDrawing(provider.getActiveActions()));
          break;
      }
    }

    ColorPicker colorPicker = ColorPicker(
      pickerColor: pickerColor,
      onColorChanged: changeColor,
      colorPickerWidth: 200,
      pickerAreaHeightPercent: 0.7,
      enableAlpha: false,
      displayThumbColor: true,
      paletteType: PaletteType.hueWheel,
      labelTypes: const [],
      portraitOnly: true,
    );

    void changeBackgroundColor(Color color) {
      setState(() => pickerColor = color);
      switch(widget.boxAction.elementName){
        case "textButton":
          ICTextButton textButton = widget.boxAction.element as ICTextButton;
          ICButtonStyle style = textButton.style;
          style.setBackgroundColor(color:ICColor("0xff${colorToHex(color,enableAlpha:false)}"));

          widget.boxAction.element = textButton;
          provider.updateSource(compileDrawing(provider.getActiveActions()));
          break;
      }
    }

    ColorPicker bgColorPicker = ColorPicker(
      pickerColor: pickerColor,
      onColorChanged: changeBackgroundColor,
      colorPickerWidth: 200,
      pickerAreaHeightPercent: 0.7,
      enableAlpha: false,
      displayThumbColor: true,
      paletteType: PaletteType.hueWheel,
      labelTypes: const [],
      portraitOnly: true,
    );

    void changeFont(String font){
      setState(() => selectedFont = font);
      switch(widget.boxAction.elementName){
        case "text":
          ICText text = widget.boxAction.element as ICText;
          ICTextStyle style = text.textStyle;
          style.setFontFamily(font);
          text.setStyle(style);
          provider.updateSource(compileDrawing(provider.getActiveActions()));
          break;
        case "textButton":
          ICTextButton textButton = widget.boxAction.element as ICTextButton;
          ICTextStyle textStyle = textButton.child.textStyle;
          textStyle.setFontFamily(font);
          textButton.child.setStyle(textStyle);
          provider.updateSource(compileDrawing(provider.getActiveActions()));

      }
    }

    List<DropdownMenuEntry> fonts = fontOptions.map((value){return DropdownMenuEntry(label:value, value:value, labelWidget:Text(value, style: GoogleFonts.getFont(value),));}).toList();

    DropdownMenu fontDropdown = DropdownMenu(dropdownMenuEntries: fonts, onSelected: (value)=>changeFont(value));

    switch (widget.boxAction.elementName) {
      case "text":
        tabs.add(const Tab(icon: Icon(Icons.format_color_text)));
        tabViews.add(Column(children:[Expanded(child:colorPicker)]));
        tabs.add(const Tab(icon: Icon(Icons.font_download_outlined)));
        tabViews.add(SingleChildScrollView(child:fontDropdown),);
        break;
      case "icon":
        tabs.add(const Tab(icon: Icon(Icons.format_color_fill)));
        tabViews.add(Column(children:[Expanded(child:colorPicker)]));
        break;
      case "textButton":
        tabs.add(const Tab(icon: Icon(Icons.format_color_text)));
        tabViews.add(Column(children:[Expanded(child:colorPicker)]));
        tabs.add(const Tab(icon: Icon(Icons.font_download_outlined)));
        tabViews.add(SingleChildScrollView(child:fontDropdown),);
        tabs.add(const Tab(icon: Icon(Icons.format_color_fill)));
        tabViews.add(Column(children:[Expanded(child:bgColorPicker)]));

        break;
    }

    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade700)),
        height: 300,
        width: 200,
          child: DefaultTabController(
              length: tabs.length,
              child:Column(children: [
                TabBar(tabs: tabs, isScrollable: true),
                SizedBox(height:250, child:TabBarView(
                  children: tabViews,
                ))
              ])));
  }
}
