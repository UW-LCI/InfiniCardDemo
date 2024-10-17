import 'package:flutter/material.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICTextStyle.dart';

class ICAppBarTheme {
  AppBarTheme theme = const AppBarTheme();

  ICTextStyle? toolbarStyle;
  ICTextStyle? titleStyle;
  ICColor? bgColor;
  ICColor? fgColor;

  ICAppBarTheme();

  void toolbarTextStyle(ICTextStyle? style) {
    if (style != null) {
      toolbarStyle = style;
    }
  }

  void titleTextStyle(ICTextStyle? style) {
    if (style != null) {
      titleStyle = style;
    }
  }

  void backgroundColor(ICColor? color) {
    if (color != null) {
      bgColor = color;
    }
  }

  void foregroundColor(ICColor? color) {
    if (color != null) {
      fgColor = color;
    }
  }

  AppBarTheme toFlutter() {
    return theme.copyWith(
        toolbarTextStyle: toolbarStyle?.toFlutter(),
        titleTextStyle: titleStyle?.toFlutter(),
        backgroundColor: bgColor?.toFlutter(),
        foregroundColor: fgColor?.toFlutter());
  }

  XmlElement toXml({bool verbose = false}) {
    final element = XmlElement(XmlName("appBarTheme"),[],[XmlText("")]);
    final propertiesElement = XmlElement(XmlName("properties"));

    final toolStyleElement = toolbarStyle != null ? toolbarStyle!.toXml(verbose: verbose, name:"toolbarTextStyle") : XmlElement(XmlName("toolbarTextStyle"),[],[XmlText("")]);
    final titleStyleElement = titleStyle != null ? titleStyle!.toXml(verbose: verbose, name:"titleTextStyle") : XmlElement(XmlName("titleTextStyle"),[],[XmlText("")]);
    
    final bgElement = bgColor != null ? XmlElement(XmlName("backgroundColor"),[],[XmlText(bgColor!.toColorString())]) : XmlElement(XmlName("backgroundColor"), [], [XmlText("")]);
    final fgElement = fgColor != null ? XmlElement(XmlName("foregroundColor"),[],[XmlText(fgColor!.toColorString())]) : XmlElement(XmlName("foregroundColor"), [], [XmlText("")]);

    if(verbose==false){
      if(toolbarStyle!=null){propertiesElement.children.add(toolStyleElement);}
      if(titleStyle!=null){propertiesElement.children.add(titleStyleElement);}
      if(bgColor!=null){propertiesElement.children.add(bgElement);}
      if(fgColor!=null){propertiesElement.children.add(fgElement);}
      if(propertiesElement.children.isNotEmpty){element.children.add(propertiesElement);}
    } else {
      propertiesElement.children.add(toolStyleElement);
      propertiesElement.children.add(titleStyleElement);
      propertiesElement.children.add(bgElement);
      propertiesElement.children.add(fgElement);
      element.children.add(propertiesElement);
    }
    return element;
  }
}
