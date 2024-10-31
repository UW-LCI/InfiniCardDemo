import 'package:flutter/material.dart';
import 'package:infinicard_v1/functions/buildUI/buildFromXml.dart';
import 'package:infinicard_v1/functions/buildUI/buildTheme.dart';
import 'package:infinicard_v1/objects/ICObject.dart';
import 'package:infinicard_v1/objects/ICThemeData.dart';
import 'package:xml/xml.dart';

class infinicardApp {
  String xmlString;
  ICThemeData? theme;
  List<ICObject> widgets = [];

  infinicardApp(this.xmlString){
    theme = getTheme(xmlString);
  }

  Widget toFlutter(){
  return MaterialApp(
    theme: theme?.toFlutter(),
    home: Scaffold(
      body: Builder(
        builder: (context) {
          widgets = getXML(xmlString, context);
          return buildXML(widgets, context);
        },
      ),
    ),
  );
  }

  XmlElement toXml({bool verbose=false}){
    var rootElement = XmlElement(XmlName("root"));
    var uiElement = XmlElement(XmlName("ui"),[],[XmlText("")]);
    var themeElement = theme != null ? theme!.toXml(verbose: verbose) :XmlElement(XmlName("theme"),[],[XmlText("")]);

    for(var element in widgets){
      uiElement.children.add(element.toXml(verbose:verbose));
    }
    
    rootElement.children.add(uiElement);
    rootElement.children.add(themeElement);
    return rootElement;
  }
}
