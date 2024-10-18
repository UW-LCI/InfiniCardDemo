import 'package:flutter/material.dart';
import 'package:infinicard_v1/objects/ICTextButton.dart';
import 'package:infinicard_v1/functions/buildButtonStyle.dart';
import 'package:infinicard_v1/functions/buildText.dart';

import 'package:xml/xml.dart';

import 'helpers.dart';

ICTextButton getTextButton(XmlElement button, BuildContext context){
  var properties = button.getElement("properties");
  var propertiesList = properties != null ? properties.childElements : const Iterable.empty();

  var textButton = ICTextButton();

  for (XmlElement property in propertiesList) {
    var type = property.name.toString();
    switch (type) {
      case "child":
        if(property.firstElementChild != null){
          textButton.setChild(getText(property.firstElementChild!, context));
        }
        break;
      case "onPressed":
        textButton.setAction(getAction(property));
        break;
      case "size":
        var size = getSize(property);
        textButton.setSize(heightArg:size[0], widthArg:size[1]);
      case "buttonStyle":
        textButton.setStyle(getButtonStyle(property));
        break;
      default:
        debugPrint("Tried to build unrecognized button property: $type");

    }
  }

  return textButton;
  
}

Widget buildTextButton(XmlElement button, BuildContext context){
  var textButton = getTextButton(button, context);
  var height = textButton.height;
  var width = textButton.width;

  return SizedBox(height: height, width: width, child: textButton.toFlutter(context));
}


