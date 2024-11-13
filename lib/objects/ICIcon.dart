import 'package:flutter/material.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICObject.dart';

class ICIcon extends ICObject{
  IconData? icon;
  String iconName = "error";
  ICColor? iconColor;
  double? iconSize;

  @override
  double? height;
  @override
  double? width;
  
  @override
  double? top;
  @override
  double? left;

  int id = -1;

  ICIcon();

  void setIcon(String name){
    iconName = name;
    icon = getIcon(iconName);
  }

  void setColor(ICColor? color){
    iconColor = color;
  }

  void setIconSize(double? size){
    iconSize = size;
  }

  void setSize({double? heightArg, double? widthArg}){
    height = heightArg;
    width = widthArg;
  }

  void setLocation({double? topArg, double? leftArg}){
    top = topArg;
    left = leftArg;
  }

  @override
  ICIcon copyWith({int? newID}) {
    ICIcon newIcon = ICIcon();
    newIcon.id = newID ?? -1;

    newIcon.icon = icon;
    newIcon.iconColor = iconColor;
    newIcon.iconName = iconName;
    newIcon.iconSize = iconSize;

    newIcon.height = height;
    newIcon.width = width;

    newIcon.top = top;
    newIcon.left = left;

    return newIcon;
  }

  @override
  Widget toFlutter(BuildContext context){
    return Icon(icon, color: iconColor?.toFlutter(), size: iconSize);
  }

  @override
  XmlElement toXml({verbose=false}){
    final element = XmlElement(XmlName('icon'),[XmlAttribute(XmlName("id"), id.toString())],[]);
    final propertiesElement = XmlElement(XmlName("properties"), [], [XmlText("")]);

    final iconElement = icon != null ? XmlElement(XmlName("iconName"),[],[XmlText(iconName)]) : XmlElement(XmlName("iconName"),[],[XmlText("")]);
    final colorElement = iconColor != null ? XmlElement(XmlName("color"),[],[XmlText(iconColor!.toColorString())]) : XmlElement(XmlName("color"),[],[XmlText("")]);
    final iconSizeElement = iconSize != null ? XmlElement(XmlName("iconSize"),[],[XmlText(iconSize.toString())]) : XmlElement(XmlName("iconSize"),[],[XmlText("")]);
    
    final sizeElement = XmlElement(XmlName("size"));
    final heightElement = (height!= null) ? XmlElement(XmlName("height"), [], [XmlText(height.toString())]) : XmlElement(XmlName("height"), [], [XmlText("")]);
    final widthElement = (width!= null) ? XmlElement(XmlName("width"), [], [XmlText(width.toString())]) : XmlElement(XmlName("width"), [], [XmlText("")]);

    final locationElement = XmlElement(XmlName("location"));
    final topElement = (height!= null) ? XmlElement(XmlName("top"), [], [XmlText(top.toString())]) : XmlElement(XmlName("top"), [], [XmlText("")]);
    final leftElement = (width!= null) ? XmlElement(XmlName("left"), [], [XmlText(left.toString())]) : XmlElement(XmlName("left"), [], [XmlText("")]);

    if(verbose==false){
      if(icon!=null){propertiesElement.children.add(iconElement);}
      if(iconColor!=null){propertiesElement.children.add(colorElement);}
      if(iconSize!=null){propertiesElement.children.add(iconSizeElement);}

      if(height != null){sizeElement.children.add(heightElement);}
      if(width != null){sizeElement.children.add(widthElement);}
      if(sizeElement.children.isNotEmpty){propertiesElement.children.add(sizeElement);}

      if(top != null){locationElement.children.add(topElement);}
      if(left != null){locationElement.children.add(leftElement);}
      if(locationElement.children.isNotEmpty){propertiesElement.children.add(locationElement);}

      if(propertiesElement.children.isNotEmpty){element.children.add(propertiesElement);}
    } else {
      propertiesElement.children.add(iconElement);
      propertiesElement.children.add(colorElement);
      propertiesElement.children.add(iconSizeElement);

      sizeElement.children.add(heightElement);
      sizeElement.children.add(widthElement);
      propertiesElement.children.add(sizeElement);

      locationElement.children.add(topElement);
      locationElement.children.add(leftElement);
      propertiesElement.children.add(locationElement);

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