import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICObject.dart';

class ICColumn extends ICObject{
  List<ICObject> children;

  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.spaceBetween;
  MainAxisSize mainAxisSize = MainAxisSize.max;
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;

  int id = -1;

  @override
  double? height = 10;
  @override
  double? width = 10;
  
  @override
  double? top = 10;
  @override
  double? left = 10;

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

  void setSize({double? heightArg, double? widthArg}){
    height = heightArg;
    width = widthArg;
  }

  void setLocation({double? topArg, double? leftArg}){
    top = topArg;
    left = leftArg;
  }

  @override
  ICColumn copyWith({int? newID}) {
    ICColumn newColumn = ICColumn([]);
    newColumn.id = newID ?? -1;
    for(ICObject child in children){
      newColumn.children.add(child.copyWith(newID: UniqueKey().hashCode));
    }

    newColumn.mainAxisAlignment = mainAxisAlignment;
    newColumn.mainAxisSize = mainAxisSize;
    newColumn.crossAxisAlignment = crossAxisAlignment;

    newColumn.height = height;
    newColumn.width = width;

    newColumn.top = top;
    newColumn.left = left;

    return newColumn;
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
    final element = XmlElement(XmlName('column'),[XmlAttribute(XmlName("id"), id.toString())],[]);
    final propertiesElement = XmlElement(XmlName("properties"));

    propertiesElement.children.add(XmlElement(XmlName("mainAxisAlignment"),[],[XmlText(mainAxisAlignment.toString())]));
    propertiesElement.children.add(XmlElement(XmlName("crossAxisAlignment"),[],[XmlText(crossAxisAlignment.toString())]));
    propertiesElement.children.add(XmlElement(XmlName("mainAxisSize"),[],[XmlText(mainAxisSize.toString())]));

    final sizeElement = XmlElement(XmlName("size"));
    final heightElement = (height!= null) ? XmlElement(XmlName("height"), [], [XmlText(height.toString())]) : XmlElement(XmlName("height"), [], [XmlText("")]);
    final widthElement = (width!= null) ? XmlElement(XmlName("width"), [], [XmlText(width.toString())]) : XmlElement(XmlName("width"), [], [XmlText("")]);

    final locationElement = XmlElement(XmlName("location"));
    final topElement = (height!= null) ? XmlElement(XmlName("top"), [], [XmlText(top.toString())]) : XmlElement(XmlName("top"), [], [XmlText("")]);
    final leftElement = (width!= null) ? XmlElement(XmlName("left"), [], [XmlText(left.toString())]) : XmlElement(XmlName("left"), [], [XmlText("")]);

    sizeElement.children.add(heightElement);
    sizeElement.children.add(widthElement);
    propertiesElement.children.add(sizeElement);

    locationElement.children.add(topElement);
    locationElement.children.add(leftElement);
    propertiesElement.children.add(locationElement);

    element.children.add(propertiesElement);

    final childElements = XmlElement(XmlName("children"), [], [XmlText("")]);

    var xmlChildren = children.map((child) => child.toXml(verbose: verbose)).toList();
    childElements.children.addAll(xmlChildren);

    element.children.add(childElements);
    return element;
  }
}
