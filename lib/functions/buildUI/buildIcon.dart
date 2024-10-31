import 'package:flutter/material.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICIcon.dart';
import '../helpers.dart';

ICIcon getIcon(XmlElement iconElement, BuildContext context){
  final properties = iconElement.getElement("properties");

  var icon = ICIcon();

  final propertiesList = properties != null ? properties.childElements : const Iterable.empty();
  for (XmlElement property in propertiesList) {
    var type = property.name.toString();
    switch (type) {
      case "iconName":
        icon.setIcon(property.innerText);
        break;
      case "color":
        icon.setColor(ICColor(property.innerText));
        break;
      case "iconSize":
        icon.setIconSize(getDouble(property));
        break;
      case "size":
        var size = getSize(property);
        icon.setSize(heightArg:size[0], widthArg:size[1]);
      case "location":
        var location = getLocation(property);
        icon.setLocation(topArg: location[0], leftArg: location[1]);
    }
  }
  return icon;
}