import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICImage.dart';
import 'helpers.dart';

ICImage getImage(XmlElement imageElement, BuildContext context) {
  var properties = imageElement.getElement("properties");
  var path = imageElement.getElement("path");

  var image = ICImage(getImgPath(path));

  var propertiesList = properties != null ? properties.childElements : const Iterable.empty();
  for (XmlElement property in propertiesList) {
    var type = property.name.toString();
    switch (type) {
      case "altText":
        image.setAltText(getString(property));
        break;
      case "size":
        var size = getSize(property);
        image.setSize(heightArg:size[0], widthArg:size[1]);
        break;
      case "shape":
        image.setShape(getString(property));
        break;
      default:
        debugPrint("Tried to build unrecognized property: $type"); //switch to exception
    }
  }

  return image;
}

Widget buildImage(XmlElement imageElement, BuildContext context){
  var image = getImage(imageElement, context);
  var height = image.height;
  var width = image.width;

  return SizedBox(height: height, width: width, child: image.toFlutter(context));
}