import 'package:flutter/material.dart';
import 'package:infinicard_v1/fonts.dart';
import 'package:infinicard_v1/functions/compileXML/compileDrawing.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinicard_v1/objects/ICButtonStyle.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:infinicard_v1/objects/ICIcon.dart';
import 'package:infinicard_v1/objects/ICIconButton.dart';
import 'package:infinicard_v1/objects/ICImage.dart';
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

  String selectedFont = "Lato";
  String visibleElement = "";

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<InfinicardStateProvider>(context, listen: false);

    void changeColor(Color color) {
      setState(() => pickerColor = color);
      switch(widget.boxAction.elementName){
        case "text":
          ICText text = widget.boxAction.element as ICText;
          ICTextStyle style = ICTextStyle();
          style.textColor = ICColor("0xff${colorToHex(color,enableAlpha:false)}");
          text.setStyle(style);
          provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));
          break;
        case "icon":
          ICIcon icon = widget.boxAction.element as ICIcon;
          icon.setColor(ICColor("0xff${colorToHex(color,enableAlpha:false)}"));
          provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));
          break;
        case "iconButton":
          ICIconButton iconButton = widget.boxAction.element as ICIconButton;
          iconButton.icon.setColor(ICColor("0xff${colorToHex(color,enableAlpha:false)}"));
          provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));
          break;
        case "textButton":
          ICTextButton textButton = widget.boxAction.element as ICTextButton;
          ICText text = textButton.child;
          ICTextStyle style = ICTextStyle();
          style.textColor = ICColor("0xff${colorToHex(color,enableAlpha:false)}");
          text.setStyle(style);
          textButton.child = text;
          provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));
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
          provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));
          break;
        case "iconButton":
          ICIconButton iconButton = widget.boxAction.element as ICIconButton;
          ICButtonStyle style = iconButton.style;
          style.setBackgroundColor(color:ICColor("0xff${colorToHex(color,enableAlpha:false)}"));
          provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));
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
      debugPrint(selectedFont);

      switch(widget.boxAction.elementName){
        case "text":
          ICText text = widget.boxAction.element as ICText;
          ICTextStyle style = text.textStyle;
          style.setFontFamily(font);
          text.setStyle(style);
          provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));
          break;
        case "textButton":
          ICTextButton textButton = widget.boxAction.element as ICTextButton;
          ICTextStyle textStyle = textButton.child.textStyle;
          textStyle.setFontFamily(font);
          textButton.child.setStyle(textStyle);
          provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));

      }
    }

    void updateWeight(){
      switch(widget.boxAction.elementName){
        case "text":
          ICText text = widget.boxAction.element as ICText;
          ICTextStyle style = text.textStyle;
          FontWeight? weight = style.fontWeight;
          if(weight == FontWeight.w400 || weight==null || weight == FontWeight.normal){
            weight = FontWeight.bold;
          } else {
            weight = FontWeight.normal;
          }
          style.setFontWeight(weight);
          text.setStyle(style);
          provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));
          break;
        case "textButton":
          ICTextButton textButton = widget.boxAction.element as ICTextButton;
          ICText text = textButton.child;
          ICTextStyle style = text.textStyle;
          FontWeight? weight = style.fontWeight;
          if(weight == FontWeight.w400 || weight==null || weight == FontWeight.normal){
            weight = FontWeight.bold;
          } else {
            weight = FontWeight.normal;
          }
          style.setFontWeight(weight);
          text.setStyle(style);
          provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));
          break;
        default:
          break;
      }
    }

    void updateShape(String shape){
      switch(widget.boxAction.elementName){
        case "image":
          ICImage image = widget.boxAction.element as ICImage;
          image.setShape(shape);
          provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));
          break;
      }
    }

    List<DropdownMenuEntry> fonts = fontOptions.map((value){return DropdownMenuEntry(label:value, value:value, labelWidget:Text(value, style: GoogleFonts.getFont(value),));}).toList();

    DropdownMenu fontDropdown = DropdownMenu(dropdownMenuEntries: fonts, initialSelection: selectedFont, onSelected: (value)=>changeFont(value));
    IconButton bold = IconButton(icon: Icon(Icons.format_bold), onPressed: (){updateWeight();});
    Container textEditor = Container(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[fontDropdown, bold]));

    IconButton textColor = IconButton(icon: Icon(Icons.format_color_text), onPressed: (){setState((){visibleElement = "colorPicker"; provider.styleVisibility = true;});},);
    IconButton font = IconButton(icon: Icon(Icons.font_download_outlined), onPressed: (){setState((){visibleElement = "font"; provider.styleVisibility = true;});},);
    IconButton iconColor = IconButton(icon: Icon(Icons.format_color_fill), onPressed: (){setState((){visibleElement = "colorPicker"; provider.styleVisibility = true;});},);
    IconButton bgColor = IconButton(icon: Icon(Icons.format_color_fill), onPressed: (){setState((){visibleElement = "bgColorPicker"; provider.styleVisibility = true;});},);
    
    IconButton shape = IconButton(icon:Icon(Icons.format_shapes), onPressed: (){setState((){visibleElement = "shape"; provider.styleVisibility = true;});});
    IconButton rounded = IconButton(icon:Icon(Icons.rounded_corner), onPressed: (){updateShape("roundedrectangle");});
    IconButton rectangle = IconButton(icon:Icon(Icons.rectangle_outlined), onPressed: (){updateShape("rectangle");});
    IconButton circle = IconButton(icon:Icon(Icons.circle_outlined), onPressed: (){updateShape("circle");});
    Row shapeEditor = Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children:[rounded, rectangle, circle]);
    
    List<IconButton> options = [];
    switch (widget.boxAction.elementName) {
      case "text":
        options.add(textColor);
        options.add(font);

        ICText text = widget.boxAction.element as ICText;
        selectedFont = text.textStyle.fontFamily ?? "Lato";
        Color? color = text.textStyle.textColor != null? text.textStyle.textColor!.toFlutter() : Colors.white;
        pickerColor = color ?? Colors.white;
        break;
      case "icon":
        options.add(iconColor);

        break;
      case "iconButton":
        options.add(iconColor);
        options.add(bgColor);

        break;
      case "textButton":
        options.add(textColor);
        options.add(font);
        options.add(bgColor);


        ICTextButton textButton = widget.boxAction.element as ICTextButton;
        ICText text = textButton.child;
        selectedFont = text.textStyle.fontFamily ?? "Lato";
        Color? color = text.textStyle.textColor != null? text.textStyle.textColor!.toFlutter() : Colors.white;
        pickerColor = color ?? Colors.white;
        break;
      case "image":
        options.add(shape);
        break;
      case "bar":
        visibleElement = "";
        break;
    }

    Widget element = Text("hi");

    switch(visibleElement){
      case "colorPicker":
        element = colorPicker;
        break;
      case "font":
        element = Padding(padding: EdgeInsets.all(10), child:textEditor);
        break;
      case "bgColorPicker":
        element = bgColorPicker;
        break;
      case "shape":
        element = Padding(padding: EdgeInsets.all(10), child:shapeEditor);
      default:
        element = Text("hi");
    }

    return Padding(padding:EdgeInsets.only(top:10), child:Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade700),
            borderRadius: BorderRadius.all(Radius.circular(18))),
        width: 200,
        child: Column(children:[Row(children:options), Visibility(visible: provider.styleVisibility, child: SizedBox(width:200, height:220, child:element))])));
  }
}
