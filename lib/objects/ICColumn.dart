import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICObject.dart';

class ICColumn extends ICObject{
  List<ICObject> children;

  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
  MainAxisSize mainAxisSize = MainAxisSize.max;
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;

  ICColumn(this.children);

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
    return Column(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        children: flutterChildren);
  }

  @override
  XmlElement toXml({bool verbose=false}){
    final columnElement = XmlElement(XmlName("column"));
    final properties = XmlElement(XmlName("properties"));

    properties.children.add(XmlElement(XmlName("mainAxisAlignment"),[],[XmlText(mainAxisAlignment.toString())]));
    properties.children.add(XmlElement(XmlName("crossAxisAlignment"),[],[XmlText(crossAxisAlignment.toString())]));
    properties.children.add(XmlElement(XmlName("mainAxisSize"),[],[XmlText(mainAxisSize.toString())]));

    columnElement.children.add(properties);

    final childElements = XmlElement(XmlName("children"), [], [XmlText("")]);

    var xmlChildren = children.map((child) => child.toXml(verbose: verbose)).toList();
    childElements.children.addAll(xmlChildren);

    columnElement.children.add(childElements);
    return columnElement;
  }
}
