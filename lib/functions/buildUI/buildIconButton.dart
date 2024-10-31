import 'package:flutter/material.dart';
import 'package:infinicard_v1/functions/buildUI/buildButtonStyle.dart';
import 'package:infinicard_v1/functions/buildUI/buildIcon.dart';
import 'package:infinicard_v1/objects/ICIconButton.dart';

import 'package:xml/xml.dart';

import '../helpers.dart';


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
      case "iconSize":
        iconButton.setIconSize(getDouble(property));
        break;
      case "size":
        var size = getSize(property);
        iconButton.setSize(heightArg:size[0], widthArg:size[1]);
        break;
      case "location":
        var location = getLocation(property);
        iconButton.setLocation(topArg: location[0], leftArg: location[1]);
        break;
      case "buttonStyle":
        iconButton.setStyle(getButtonStyle(property));
        break;
        
      default:
        debugPrint("Tried to build unrecognized button property: $type");
    }
  }

  return iconButton;
  
}