import 'package:flutter/material.dart';
import 'package:infinicard_v1/functions/buildUI/buildText.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICAppBar.dart';
import 'package:infinicard_v1/functions/buildUI/buildFromXml.dart';
import '../helpers.dart';

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
      case "size":
        var size = getSize(property);
        appBar.setSize(heightArg:size[0], widthArg:size[1]);
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
      case "location":
        var location = getLocation(property);
        appBar.setLocation(topArg: location[0], leftArg: location[1]);
      default:
        debugPrint("Tried to build unrecognized property: $type");
    }
    
  }
  return appBar;
}
