import 'package:flutter/material.dart';
import 'package:infinicard_v1/functions/buildIcon.dart';
import 'package:infinicard_v1/objects/ICIconButton.dart';

import 'package:xml/xml.dart';

import 'helpers.dart';


ICIconButton getIconButton(XmlElement button, BuildContext context){
  var properties = button.getElement("properties");
  var propertiesList = properties != null ? properties.childElements : const Iterable.empty();

  var iconButton = ICIconButton();

  for (var property in propertiesList) {
    var type = property.name.toString();
    switch (type) {
      case "icon":
        iconButton.setIcon(getIcon(property, context));
        break;
      case "onPressed":
        iconButton.setAction(getAction(property));
        break;
      case "size":
        iconButton.setSize(getDouble(property));
      default:
        debugPrint("Tried to build unrecognized button property: $type");
    }
  }

  return iconButton;
  
}