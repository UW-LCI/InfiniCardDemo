import 'package:flutter/material.dart';
import 'package:infinicard_v1/functions/buildUI/buildFromXml.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import 'package:infinicard_v1/objects/ICTextStyle.dart';
import 'package:infinicard_v1/objects/ICObject.dart';


double? getFontSize(XmlElement sizeElement){
  final sizeVal = sizeElement.innerText.toString();
  double? size;
  try{
    size = double.parse(sizeVal.toLowerCase().replaceAll(' ', ''));
  } on Exception {
    debugPrint("Failed to interpret double value $sizeVal");
    size = null;
  }
  return size;
}

FontWeight getFontWeight(XmlElement weightElement){
  var weightName = weightElement.innerText.toString();
  FontWeight weight;
  switch(weightName.toLowerCase()){
    case "fontweight.w100" || "thin":
      weight = FontWeight.w100;
      break;
    case "fontweight.w200" || "extra-light":
      weight = FontWeight.w200;
      break;
    case "fontweight.w300" || "light":
      weight = FontWeight.w300;
      break;
    case "fontweight.w400" || "normal":
      weight = FontWeight.w400;
      break;
    case "fontweight.w500" || "medium":
      weight = FontWeight.w500;
      break;
    case "fontweight.w600" || "semi-bold":
      weight = FontWeight.w600;
      break;
    case "fontweight.w700" || "bold":
      weight = FontWeight.w700;
      break;
    case "fontweight.w800" || "extra-bold":
      weight = FontWeight.w800;
      break;
    case "fontweight.w900" || "black":
      weight = FontWeight.w900;
      break;
    default:
      weight = FontWeight.normal;
  }
  return weight;
}

String getFontFamily(XmlElement fontElement){
  var fontFamily = fontElement.innerText.toString();
  return fontFamily;
}


ICTextStyle getTextStyle(XmlElement styleElement){
  var style = ICTextStyle();
  var properties = styleElement.childElements;
  for(var property in properties){
    var type = property.name.toString();
    switch(type){
      case "color": 
        style.color(ICColor(property.innerText));
        break;
      case "fontSize":
        style.setFontSize(getFontSize(property));
        break;
      case "fontWeight":
        style.setFontWeight(getFontWeight(property));
        break;
      case "fontFamily":
        style.setFontFamily(getFontFamily(property));
        break;
      default:
        debugPrint("Tried to build unrecognized text style: $type");
    }
  }
  return style;
}

bool? getCenter(XmlElement centerElement){
  String centerVal = centerElement.innerText.toString();
  bool? center;
  try{
    center = bool.parse(centerVal.toLowerCase().replaceAll(' ', ''));
  } on Exception catch(_) {
    debugPrint("Failed to interpret bool value $centerVal");
    center=null;
  }
  
  return center;
}

double? getHeight(XmlElement heightElement){
  final heightVal = heightElement.innerText.toString();
  double? height;
  try{
    height = double.parse(heightVal.toLowerCase().replaceAll(' ', ''));
  } on Exception catch(_) {
    debugPrint("Failed to interpret double value $heightVal");
    height = null;
  }
  return height;
}

double? getDouble(XmlElement numElement){
  final val = numElement.innerText.toString();
  double? number;
  try{
    number = double.parse(val.toLowerCase().replaceAll(' ', ''));
  } on Exception catch(_) {
    debugPrint("Failed to interpret double value $val");
    number = null;
  }
  return number;
}

double? getWidth(XmlElement widthElement){
  final widthVal = widthElement.innerText.toString();
  double? width;
  try{
    width = double.parse(widthVal.toLowerCase().replaceAll(' ', ''));
  } on Exception catch(_) {
    debugPrint("Failed to interpret double value $widthVal");
    width = null;
  }
  return width;
}

List<double?> getSize(XmlElement sizeElement){
  var heightElement = sizeElement.getElement("height");
  var height = heightElement != null ? getHeight(heightElement) : null;
  
  var widthElement = sizeElement.getElement("width");
  var width = widthElement != null ? getWidth(widthElement) : null;
  
  return [height, width];
}

List<double?> getLocation(XmlElement locationElement){
  var topElement = locationElement.getElement("top");
  var top = topElement != null ? getDouble(topElement) : null;
  
  var leftElement = locationElement.getElement("left");
  var left = leftElement != null ? getDouble(leftElement) : null;
  
  return [top, left];
}

String getString(XmlElement? string){
  var value = string != null ? string.innerText.toString() : "";
  return value;
}

String getImgPath(XmlElement? path){
  List<String> validImagePaths = ['error.png', 'pendingImage.png', 'upload.png'];
  String value = path != null ? path.innerText.toString() : "";
  if(validImagePaths.contains(value)){
    return value;
  } else {
    return "error.png";
  }
}

TextAlign getTextAlign(XmlElement textAlign){
  var alignValue = textAlign.innerText.toString();
  TextAlign align;
  switch(alignValue){
    case "right":
      align = TextAlign.right;
      break;
    case "left":
      align = TextAlign.left;
      break;
    case "center":
      align = TextAlign.center;
      break;
    case "justify":
      align = TextAlign.justify;
      break;
    case "start":
      align = TextAlign.start;
      break;
    case "end":
      align = TextAlign.end;
      break;
    default:
      align = TextAlign.left;
  }
  return align;
}

MainAxisAlignment getMainAxisAlignment(XmlElement alignment){
  var alignValue = alignment.innerText.toString();
  MainAxisAlignment align;
  switch(alignValue){
    case "center" || "MainAxisAlignment.center":
      align = MainAxisAlignment.center;
      break;
    case "start" || "MainAxisAlignment.start":
      align = MainAxisAlignment.start;
      break;
    case "end" || "MainAxisAlignment.end":
      align = MainAxisAlignment.end;
      break;
    case "spaceBetween" || "MainAxisAlignment.spaceBetween":
      align = MainAxisAlignment.spaceBetween;
      break;
    case "spaceAround" || "MainAxisAlignment.spaceAround":
      align = MainAxisAlignment.spaceAround;
      break;
    case "spaceEvenly" || "MainAxisAlignment.spaceEvenly":
      align = MainAxisAlignment.spaceEvenly;
      break;
    default:
      align = MainAxisAlignment.start;
  }
  return align;
}

MainAxisSize getMainAxisSize(XmlElement alignment){
  var alignValue = alignment.innerText.toString();
  MainAxisSize align;
  switch(alignValue){
    case "min" || "MainAxisSize.min":
      align = MainAxisSize.min;
      break;
    case "max" || "MainAxisSize.max":
      align = MainAxisSize.max;
      break;
    default:
      align = MainAxisSize.max;
  }
  return align;
}

CrossAxisAlignment getCrossAxisAlignment(XmlElement alignment){
  var alignValue = alignment.innerText.toString();
  CrossAxisAlignment align;
  switch(alignValue){
    case "center" || "CrossAxisAlignment.center":
      align = CrossAxisAlignment.center;
      break;
    case "start" || "CrossAxisAlignment.start":
      align = CrossAxisAlignment.start;
      break;
    case "end" || "CrossAxisAlignment.end":
      align = CrossAxisAlignment.end;
      break;
    case "stretch" || "CrossAxisAlignment.stretch":
      align = CrossAxisAlignment.stretch;
      break;
    case "baseline" || "CrossAxisAlignment.baseline":
      align = CrossAxisAlignment.baseline;
      break;
    default:
      align = CrossAxisAlignment.center;
  }
  return align;
}

List<ICObject> getActions(XmlElement action, context){
  var actionsList = action.childElements;
  List<ICObject> actions = [];

  for(var action in actionsList){
    actions.add(getUIElement(action, context));
  }
  return actions;
}

void onPressed(Map? action){
    var type = action?['type'];
    var target = action?['target'];

    if (type == 'link') {
      launchUrl(Uri.parse(target));
    }
  }

Map getAction(XmlElement onPressedElement){
  var action = {};
  action['type'] = null;
  action['target'] = null;
  var typeElement = onPressedElement.getElement('type');
  if(typeElement!=null){
    var type = typeElement.innerText.toString();
    if(type=="link"){
      var targetElement = onPressedElement.getElement('target');
      if(targetElement!=null){
        var target = targetElement.innerText.toString();
        action['type'] = 'link';
        action['target'] = target;
      }
    }
  }
  return action;
}

bool contained(BoxAction parent, BoxAction child) {
  if (parent.rect.contains(child.rect.topLeft) &&
      parent.rect.contains(child.rect.topRight) &&
      parent.rect.contains(child.rect.bottomLeft) &&
      parent.rect.contains(child.rect.bottomRight)) {
    return true;
  } else {
    return false;
  }
}