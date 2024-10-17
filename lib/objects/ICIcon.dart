import 'package:flutter/material.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICObject.dart';

class ICIcon extends ICObject{
  IconData? icon;
  String iconName = "error";
  ICColor? iconColor;
  double? iconSize;

  ICIcon();

  void setIcon(String name){
    iconName = name;
    icon = getIcon(iconName);
  }

  void setColor(ICColor? color){
    iconColor = color;
  }

  void setSize(double? size){
    iconSize = size;
  }

  @override
  Widget toFlutter(BuildContext context){
    return Icon(icon, color: iconColor?.toFlutter(), size: iconSize);
  }

  @override
  XmlElement toXml({verbose=false}){
    final element = XmlElement(XmlName("icon"),[],[XmlText("")]);
    final propertiesElement = XmlElement(XmlName("properties"), [], [XmlText("")]);

    final iconElement = icon != null ? XmlElement(XmlName("iconName"),[],[XmlText(iconName)]) : XmlElement(XmlName("iconName"),[],[XmlText("")]);
    final colorElement = iconColor != null ? XmlElement(XmlName("color"),[],[XmlText(iconColor!.toColorString())]) : XmlElement(XmlName("color"),[],[XmlText("")]);
    final sizeElement = iconSize != null ? XmlElement(XmlName("size"),[],[XmlText(iconSize.toString())]) : XmlElement(XmlName("size"),[],[XmlText("")]);
    
    if(verbose==false){
      if(icon!=null){propertiesElement.children.add(iconElement);}
      if(iconColor!=null){propertiesElement.children.add(colorElement);}
      if(iconSize!=null){propertiesElement.children.add(sizeElement);}
      if(propertiesElement.children.isNotEmpty){element.children.add(propertiesElement);}
    } else {
      propertiesElement.children.add(iconElement);
      propertiesElement.children.add(colorElement);
      propertiesElement.children.add(sizeElement);
      element.children.add(propertiesElement);
    }

    return element;
  }

  IconData getIcon(String name){
    IconData icon;
    switch(name){
      case "account_circle":
        icon = Icons.account_circle;
      case "brightness_2":
        icon = Icons.brightness_2;
      case "brightness_5_rounded":
        icon = Icons.brightness_5_rounded;
      case "email":
        icon = Icons.email;
      case "school_rounded":
        icon = Icons.school_rounded;
      default:
        icon = Icons.question_mark;
    }
    return icon;
  }
}