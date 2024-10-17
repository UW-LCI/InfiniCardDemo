import 'package:flutter/material.dart';
import 'package:infinicard_v1/functions/buildText.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICAppBar.dart';
import 'package:infinicard_v1/functions/buildFromXml.dart';
import 'helpers.dart';

ICAppBar getBar(XmlElement bar, BuildContext context){
  var properties = bar.getElement("properties");
  var propertiesList = properties != null ? properties.childElements : const Iterable.empty();
  
  var appBar = ICAppBar();

  //AppBar Properties
  for(XmlElement property in propertiesList){
    var type = property.name.toString();
    switch(type){
      case "backgroundColor":
        appBar.setBackgroundColor(ICColor(property.innerText));
        break;
      case "toolbarHeight":
        appBar.setToolbarHeight(getHeight(property));
        break;
      case "height":
        appBar.setHeight(getHeight(property));
        break;
      case "text":
        appBar.setTitle(getText(property, context));
        break;
      case "centerTitle":
        appBar.setCenterTitle(getCenter(property));
        break;
      case "leading":
        if(property.firstElementChild != null){
          XmlElement leading = property.firstElementChild as XmlElement;
          appBar.setLeading(getUIElement(leading, context));}
        break;
      case "actions":
        appBar.setActions(getActions(property, context));
        break;
      default:
        debugPrint("Tried to build unrecognized property: $type");
    }
    
  }
  return appBar;
}



Widget buildBar(XmlElement appBarElement, BuildContext context){
  var bar = getBar(appBarElement, context);
  var height = bar.toolbarHeight;

  return SizedBox(height:height, child:bar.toFlutter(context));
}