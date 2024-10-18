import 'package:flutter/material.dart';
import 'package:infinicard_v1/objects/ICIcon.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICObject.dart';
import 'package:infinicard_v1/functions/helpers.dart';

class ICIconButton extends ICObject{
  Map? action;
  ICIcon icon = ICIcon();

  double? size;

  ICIconButton();

  void setAction(Map actionArg){
    action = actionArg;
  }

  void setIcon(ICIcon iconArg){
    icon = iconArg;
  }

  void setSize(double? sizeArg){
    size = sizeArg;
  }  

  @override
  Widget toFlutter(BuildContext context){
    return IconButton(icon:icon.toFlutter(context), onPressed: () {onPressed(action);}, iconSize: size);
  }

  @override
  XmlElement toXml({bool verbose=false}){
    final element = XmlElement(XmlName("iconButton"));

    final propertiesElement = XmlElement(XmlName("properties"));

    final iconElement = icon.toXml(verbose:verbose);

    propertiesElement.children.add(iconElement);

    final pressedElement = XmlElement(XmlName("onPressed"));
  
    final type = action?["type"];
    final target = action?["target"];

    final typeElement = type != null ? XmlElement(XmlName("type"),[],[XmlText(type)]) : XmlElement(XmlName("type"),[],[XmlText("")]);
    final targetElement = type != null ? XmlElement(XmlName("target"),[],[XmlText(target)]) : XmlElement(XmlName("target"),[],[XmlText("")]);
      
    final sizeElement = size != null ? XmlElement(XmlName("size"), [], [XmlText(size.toString())]) : XmlElement(XmlName("size"),[],[XmlText("")]);
   
    if(verbose==false){
      if(action!=null){
        pressedElement.children.add(typeElement);
        pressedElement.children.add(targetElement);
        propertiesElement.children.add(pressedElement);
      }
      if(size!=null){propertiesElement.children.add(sizeElement);}
    } else {
      pressedElement.children.add(typeElement);
      pressedElement.children.add(targetElement);
      propertiesElement.children.add(pressedElement);

      propertiesElement.children.add(sizeElement);
    }

    element.children.add(propertiesElement);

    return element;
  }
}