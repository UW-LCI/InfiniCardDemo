import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICObject.dart';

class ICRow extends ICObject{
  List<ICObject> children;

  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
  MainAxisSize mainAxisSize = MainAxisSize.max;
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;

  ICRow(this.children);

  void setMainAxisAlignment(MainAxisAlignment alignment) {
    mainAxisAlignment = alignment;
  }

  void setMainAxisSize(MainAxisSize size) {
    mainAxisSize = size;
  }

  void setCrossAxisAlignment(CrossAxisAlignment alignment) {
    crossAxisAlignment = alignment;
  }

  @override
  Widget toFlutter(BuildContext context) {
    var flutterChildren = children.map((child) => child.toFlutter(context)).toList();
    return Row(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        children: flutterChildren);
  }

  @override
  XmlElement toXml({bool verbose=false}){
    final rowElement = XmlElement(XmlName("row"));

    final properties = XmlElement(XmlName("properties"));

    properties.children.add(XmlElement(XmlName("mainAxisAlignment"),[],[XmlText(mainAxisAlignment.toString())]));
    properties.children.add(XmlElement(XmlName("crossAxisAlignment"),[],[XmlText(crossAxisAlignment.toString())]));
    properties.children.add(XmlElement(XmlName("mainAxisSize"),[],[XmlText(mainAxisSize.toString())]));

    rowElement.children.add(properties);

    final childElements = XmlElement(XmlName("children"), [], [XmlText("")]);

    var xmlChildren = children.map((child) => child.toXml(verbose: verbose)).toList();
    childElements.children.addAll(xmlChildren);

    rowElement.children.add(childElements);
    return rowElement;
  }
}
