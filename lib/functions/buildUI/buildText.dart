import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICText.dart';
import '../helpers.dart';

ICText getText(XmlElement textElement, BuildContext context) {
  var properties = textElement.getElement("properties");
  var data = textElement.getElement("data");

  var text = ICText(getString(data));

  var propertiesList = properties != null ? properties.childElements : const Iterable.empty();
  for (XmlElement property in propertiesList) {
    var type = property.name.toString();
    switch (type) {
      case "textStyle":
        text.setStyle(getTextStyle(property));
        break;
      case "textAlign":
        text.setAlign(getTextAlign(property));
        break;
      case "size":
        var size = getSize(property);
        text.setSize(heightArg:size[0], widthArg:size[1]);
        break;
      case "location":
        var location = getLocation(property);
        text.setLocation(topArg: location[0], leftArg: location[1]);
        break;
      default:
        debugPrint("Tried to build unrecognized type: $type");

    }
  }
  return text;
}