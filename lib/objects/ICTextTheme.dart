import 'package:flutter/material.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:xml/xml.dart';

class ICTextTheme {
  TextTheme theme = Typography.blackCupertino;

  String? font;
  ICColor? textColor;

  ICTextTheme();

  void setFontFamily(String? fontFamily){
    font = fontFamily;
  }

  void setColor(ICColor? color){
    textColor = color;
  }

  TextTheme toFlutter() {
    return theme.apply(fontFamily: font, bodyColor: textColor?.toFlutter()); 
  }

  XmlElement toXml({bool verbose = false}) {
    final element = XmlElement(XmlName("textTheme"));
    final propertiesElement = XmlElement(XmlName("properties"));

    final fontElement = font != null ? XmlElement(XmlName("fontFamily"),[],[XmlText(font as String)]) : XmlElement(XmlName("fontFamily"),[],[XmlText("")]);
    final colorElement = textColor != null ? XmlElement(XmlName("color"),[],[XmlText(textColor!.toColorString())]) : XmlElement(XmlName("color"),[],[XmlText("")]);
    
    if(verbose==false){
      if(font!=null){propertiesElement.children.add(fontElement);}
      if(textColor!=null){propertiesElement.children.add(colorElement);}
      if(propertiesElement.children.isNotEmpty){element.children.add(propertiesElement);}
    } else {
      propertiesElement.children.add(fontElement);
      propertiesElement.children.add(colorElement);
      element.children.add(propertiesElement);
    }
    
    return element;
  }
}
