import 'package:flutter/material.dart';
import 'package:infinicard_v1/objects/ICRow.dart';
import 'package:infinicard_v1/objects/ICObject.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/functions/buildFromXml.dart';
import 'helpers.dart';

ICRow getRow(XmlElement child, BuildContext context){
  List<ICObject> children = [];
  var rowChildren = child.getElement("children");
  var rowChildList = rowChildren != null ? rowChildren.childElements : const Iterable.empty();
  for(XmlElement rowChild in rowChildList){
    var childElement = getUIElement(rowChild, context);
    children.add(childElement);
  }
  
  var row = ICRow(children);

  var properties = child.getElement("properties");
  var propertiesList = properties != null ? properties.childElements : const Iterable.empty();
  for(XmlElement property in propertiesList){
    var type = property.name.toString();
    switch (type) {
      case "mainAxisAlignment":
        row.setMainAxisAlignment(getMainAxisAlignment(property));
        break;
      case "mainAxisSize":
        row.setMainAxisSize(getMainAxisSize(property));
        break;
      case "crossAxisAlignment":
        row.setCrossAxisAlignment(getCrossAxisAlignment(property));
        break;
      default:

    }
  }
  return row;
}