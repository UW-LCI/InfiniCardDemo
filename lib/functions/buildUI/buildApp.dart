import 'package:flutter/material.dart';
import 'package:infinicard_v1/functions/buildUI/buildFromXml.dart';
import 'package:infinicard_v1/functions/buildUI/buildTheme.dart';
import 'package:infinicard_v1/objects/ICObject.dart';
import 'package:infinicard_v1/objects/ICPage.dart';
import 'package:infinicard_v1/objects/ICThemeData.dart';
import 'package:xml/xml.dart';

class infinicardApp {
  String xmlString;
  ICThemeData? theme;
  Map<String, ICPage> pages = {"home":ICPage(pageName: "home")};
  String startPageName = "home";

  infinicardApp(this.xmlString){
    theme = getTheme(xmlString);
    startPageName = getStartPage(xmlString);
  }

  Widget toFlutter(){
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme?.toFlutter(),
    home: Scaffold(
      body: Builder(
        builder: (context) {
          pages = getXML(xmlString, context); 
          ICPage startPage = pages[startPageName] ?? pages["home"]!;
          return startPage.toFlutter(context);
        },
      ),
    ),
  );
  }

  XmlElement toXml({bool verbose=false}){
    var rootElement = XmlElement(XmlName("root"));
    var uiElement = XmlElement(XmlName("ui"),[],[XmlText("")]);
    var themeElement = theme != null ? theme!.toXml(verbose: verbose) :XmlElement(XmlName("theme"),[],[XmlText("")]);

    if(pages.isNotEmpty){
      for(ICPage page in pages.values){
        uiElement.children.add(page.toXml(verbose:verbose));
      }
    } else {
      uiElement.children.add(ICPage().toXml());
    }
    
    rootElement.children.add(uiElement);
    rootElement.children.add(themeElement);
    return rootElement;
  }
}
