import 'package:flutter/material.dart';
import 'package:infinicard_v1/objects/ICObject.dart';
import 'package:xml/xml.dart';

class ICPage extends ICObject{
  List<ICObject> elements = [];
  String pageName = "";

  ICPage({this.pageName = ""});

  @override
  double? height = 10;
  @override
  double? width = 10;
  
  @override
  double? top = 10;
  @override
  double? left = 10;

  void setSize({double? heightArg, double? widthArg}){
    height = heightArg;
    width = widthArg;
  }

  void setLocation({double? topArg, double? leftArg}){
    top = topArg;
    left = leftArg;
  }


  Widget buildUIElement(ICObject element, BuildContext context) {
    double? elementHeight = element.height;
    double? elementWidth = element.width;

    double? elementTop = element.top != null && top!=null ? element.top! - top! : element.top;
    double? elementLeft = element.left != null && left!=null ? element.left! - left! : element.left;

    var uiElement = element.toFlutter(context);

    return Positioned(
        top: elementTop,
        left: elementLeft,
        height: elementHeight,
        width: elementWidth,
        child: uiElement,
        );
  }

  void addElement(ICObject newElement){
    newElement.pageName = pageName;
    elements.add(newElement);
  }

  void setElements(List<ICObject> allElements){
    for(ICObject each in allElements){
      each.pageName = pageName;
    }
    elements = allElements;
  }

  void rename(String name){
    pageName = name;
  }

  @override
  ICPage copyWith({int? newID}){
    return ICPage();
  }

  @override
  Widget toFlutter(BuildContext context){
    List<Widget> uiWidgets = elements.map((element) => buildUIElement(element, context)).toList();

    return Stack(alignment: Alignment(-1.0,-1.0), children: uiWidgets);
  }

  @override
  XmlElement toXml({bool verbose=false}){
    final pageElement = XmlElement(XmlName('page'), [XmlAttribute(XmlName("pageName"), pageName)], []);

    final propertiesElement = XmlElement(XmlName("properties"),[],[XmlText("")]);

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

    pageElement.children.add(propertiesElement);

    final pageElements = XmlElement(XmlName("pageElements"),[],[XmlText("")]);

    for(ICObject element in elements){
      pageElements.children.add(element.toXml());
    }

    pageElement.children.add(pageElements);

    return pageElement;
  }


}