import 'package:flutter/material.dart';
import "package:infinicard_v1/functions/buildUI/buildIcon.dart";
import "package:infinicard_v1/functions/buildUI/buildIconButton.dart";
import "package:infinicard_v1/functions/helpers.dart";
import "package:infinicard_v1/objects/ICPage.dart";
import "package:infinicard_v1/objects/ICUndefined.dart";
import 'package:xml/xml.dart';

import "buildAppBar.dart";
import "buildTextButton.dart";
import "buildImage.dart";
import "buildText.dart";
import "buildRow.dart";
import "buildColumn.dart";

import "package:infinicard_v1/objects/ICObject.dart";
import "package:infinicard_v1/objects/ICText.dart";

// Widget buildXML(List<ICObject> uiElements, BuildContext context) {
//   var uiWidgets =
//       uiElements.map((element) => buildUIElement(element, context)).toList();

//   // var target = DragTarget(
//   //     onWillAcceptWithDetails: (details) {
//   //       return true;
//   //     },
//   //     onAcceptWithDetails: (details) => {debugPrint("accept")},
//   //     builder: (
//   //       BuildContext context,
//   //       List<dynamic> accepted,
//   //       List<dynamic> rejected,
//   //     ) {
//   //       return Stack(children: uiWidgets);
//   //     });

//   return Stack(children: uiWidgets, alignment: Alignment(-1.0,-1.0),);
// }

// Widget buildXML(List<ICObject> uiElements, BuildContext context) {
//   var uiWidgets =
//       uiElements.map((element) => buildUIElement(element, context)).toList();


//   return Stack(children: uiWidgets, alignment: Alignment(-1.0,-1.0),);
// }

// List<ICObject> getPagesXML(String xml, BuildContext context) {
//   final document = XmlDocument.parse(xml);
//   final root = document.getElement("root");
//   final ui = root?.getElement("ui");
//   final elements = ui?.childElements;

//   List<ICObject> uiElements = [];
//   if (elements != null) {
//     uiElements = getUIElements(elements, context);
//   }
//   return uiElements;
// }
String getStartPage(String xml){
  final document = XmlDocument.parse(xml);
  final root = document.getElement("root");
  final ui = root?.getElement("ui");
  String? startPage = ui?.getAttribute("startPage");
  return startPage ?? "home";
}

Map<String, ICPage> getXML(String xml, BuildContext context) {
  final document = XmlDocument.parse(xml);
  final root = document.getElement("root");
  final ui = root?.getElement("ui");
  final pages = ui?.findElements("page");

  Map<String, ICPage> uiPages = {};

  if(pages!=null){
    for(XmlElement page in pages){
      final pageName = page.getAttribute("pageName");
      ICPage uiPage = ICPage(pageName: pageName ?? "home");

      final elements = page.getElement("pageElements")?.childElements ?? [];
      final properties = page.getElement("properties");
      var propertiesList = properties != null ? properties.childElements : const Iterable.empty();
      for(XmlElement property in propertiesList){
        var type = property.name.toString();
        switch (type) {
          case "size":
            var size = getSize(property);
            uiPage.setSize(heightArg:size[0], widthArg:size[1]);
            break;
          case "location":
            var location = getLocation(property);
            uiPage.setLocation(topArg: location[0], leftArg: location[1]);
            break;
          default:
        }
      }
      
      List<ICObject> uiElements = getUIElements(elements, context);
      uiPage.setElements(uiElements);
      uiPages[uiPage.pageName] = uiPage;
    }
  } 
  if(uiPages.isEmpty){
    uiPages["home"] = ICPage();
  }
  return uiPages;
}

List<ICObject> getUIElements(
    Iterable<XmlElement> elements, BuildContext context) {
  List<ICObject> uiElements = [];

  for (var child in elements) {
    if(child.name.toString() != "page"){
      uiElements.add(getUIElement(child, context));
    }
  }
  return uiElements;
}

// Widget buildUIElement(ICObject element, BuildContext context) {
//   var height = element.height;
//   var width = element.width;

//   var top = element.top;
//   var left = element.left;

//   // if(element is ICText){
//   //   return Positioned(top: top, left: left, height: height, width: width, child:FittedBox(child:element.toFlutter(context)));
//   // } else if(element is ICRow || element is ICColumn){
//   //   return Positioned(top: top, left: left, height: height, width: width, child:element.toFlutter(context));
//   // } else {
//   //   return Positioned(top: top, left: left, height: height, width: width, child: element.toFlutter(context));
//   // }
//   var uiElement = element.toFlutter(context);
//   // return Positioned(
//   //     top: top,
//   //     left: left,
//   //     height: height,
//   //     width: width,
//   //     child: Draggable(
//   //       feedback: uiElement,
//   //       onDragEnd: (dragDetails) {
//   //         left = dragDetails.offset.dx;
//   //         top = dragDetails.offset.dy;
//   //       },
//   //       data: 10,
//   //       child: uiElement,
//   //     ));
//   return Positioned(
//       top: top,
//       left: left,
//       height: height,
//       width: width,
//       child: uiElement,
//       );
// }

ICObject getUIElement(XmlElement child, BuildContext context) {
  ICObject uiElement;
  final type = child.name.toString();
  switch (type) {
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
    case "undefined":
      uiElement = ICUndefined();
    default:
      uiElement = ICText("MissingWidget");
      debugPrint("Tried to build unrecognized type: $type");
  }
  return uiElement;
}
