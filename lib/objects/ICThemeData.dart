import 'package:flutter/material.dart';
import 'package:infinicard_v1/objects/ICAppBarTheme.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICTextTheme.dart';

class ICThemeData {

  ICTextTheme? textTheme;

  ICAppBarTheme? appBarTheme;

  void setTextTheme(ICTextTheme? theme){
    textTheme = theme;
  }

  void setAppBarTheme(ICAppBarTheme? theme){
    appBarTheme = theme;
  }

  ThemeData toFlutter() { 
    return ThemeData(textTheme: textTheme?.toFlutter(), appBarTheme: appBarTheme?.toFlutter());
  }

  XmlElement toXml({bool verbose = false}) {
    final element = XmlElement(XmlName("theme"), [], [XmlText("")]);

    final appBarThemeElement = appBarTheme != null ? appBarTheme!.toXml(verbose: verbose) : XmlElement(XmlName("appBarTheme"),[],[XmlText("")]);
    final textThemeElement = textTheme != null ? textTheme!.toXml(verbose: verbose) : XmlElement(XmlName("textTheme"),[],[XmlText("")]);
    
    if(verbose==false){
      if(textTheme!=null){element.children.add(appBarThemeElement);}
      if(appBarTheme!=null){element.children.add(textThemeElement);}
    } else {
      element.children.add(appBarThemeElement);
      element.children.add(textThemeElement);
    }
    
    return element;
  }
}
