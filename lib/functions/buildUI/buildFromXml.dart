import "dart:math";

import 'package:flutter/material.dart';
import "package:infinicard_v1/functions/buildUI/buildIcon.dart";
import "package:infinicard_v1/functions/buildUI/buildIconButton.dart";
import "package:infinicard_v1/objects/ICColumn.dart";
import "package:infinicard_v1/objects/ICRow.dart";
import 'package:xml/xml.dart';

import "buildAppBar.dart";
import "buildTextButton.dart";
import "buildImage.dart";
import "buildText.dart";
import "buildRow.dart";
import "buildColumn.dart";

import "package:infinicard_v1/objects/ICObject.dart";
import "package:infinicard_v1/objects/ICText.dart";

Widget buildXML(List<ICObject> uiElements, BuildContext context){

  var uiWidgets = uiElements.map((element) => buildUIElement(element, context)).toList();

  return Stack(children:uiWidgets);
}

List<ICObject> getXML(String xml, BuildContext context){
  final document = XmlDocument.parse(xml);
  final root = document.getElement("root");
  final ui = root?.getElement("ui");
  final elements = ui?.childElements;

  List<ICObject> uiElements = [];
  if(elements!=null){uiElements = getUIElements(elements, context);}
  return uiElements;
}

List<ICObject> getUIElements(Iterable<XmlElement> elements, BuildContext context){
  List<ICObject> uiElements = [];

  for(var child in elements){
    uiElements.add(getUIElement(child, context));
  }
  return uiElements;
}

Widget buildUIElement(ICObject element, BuildContext context){
  var height = element.height;
  var width = element.width;

  var top = element.top;
  var left = element.left;

  // if(element is ICText){
  //   return Positioned(top: top, left: left, height: height, width: width, child:FittedBox(child:element.toFlutter(context)));
  // } else if(element is ICRow || element is ICColumn){
  //   return Positioned(top: top, left: left, height: height, width: width, child:element.toFlutter(context));
  // } else {
  //   return Positioned(top: top, left: left, height: height, width: width, child: element.toFlutter(context));
  // }
  return Positioned(top: top, left: left, height: height, width: width, child: element.toFlutter(context));
  
}

ICObject getUIElement(XmlElement child, BuildContext context){
  ICObject uiElement;
  final type = child.name.toString();
  switch (type){
    case "bar":
      uiElement = getBar(child, context);
      break;
    case "image":
      uiElement = getImage(child, context);
      break;
    case "textButton":
      uiElement = getTextButton(child, context);
      break;
    case "text":
      uiElement = getText(child, context);
      break;
    case "icon":
      uiElement = getIcon(child, context);
      break;
    case "iconButton":
      uiElement = getIconButton(child, context);
      break;
    case "row":
      uiElement = getRow(child, context);
      break;
    case "column":
      uiElement = getColumn(child, context);
      break;
    default:
      uiElement = ICText("MissingWidget");
      debugPrint("Tried to build unrecognized type: $type");
  }
  return uiElement;
}