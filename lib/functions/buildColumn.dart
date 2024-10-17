import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICColumn.dart';
import 'package:infinicard_v1/objects/ICObject.dart';
import 'package:infinicard_v1/functions/buildFromXml.dart';
import 'helpers.dart';

ICColumn getColumn(XmlElement child, BuildContext context){
  List<ICObject> children = [];
  var columnChildren = child.getElement("children");
  var columnChildList = columnChildren != null ? columnChildren.childElements : const Iterable.empty();
  for(var columnChild in columnChildList){
    var childElement = getUIElement(columnChild, context);
    if(childElement != null) children.add(childElement);
  }
  var column = ICColumn(children);

  var properties = child.getElement("properties");
  var propertiesList = properties != null ? properties.childElements : const Iterable.empty();
  for(XmlElement property in propertiesList){
    var type = property.name.toString();
    switch (type) {
      case "mainAxisAlignment":
        column.setMainAxisAlignment(getMainAxisAlignment(property));
        break;
      case "mainAxisSize":
        column.setMainAxisSize(getMainAxisSize(property));
        break;
      case "crossAxisAlignment":
        column.setCrossAxisAlignment(getCrossAxisAlignment(property));
        break;
      default:
    }
  }

  return column;
}