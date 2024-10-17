import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:infinicard_v1/objects/ICText.dart';
import 'package:infinicard_v1/objects/ICButtonStyle.dart';
import 'package:infinicard_v1/objects/ICObject.dart';
import 'package:infinicard_v1/functions/helpers.dart';

class ICTextButton extends ICObject{
  Map? action;
  ICText child = ICText("");

  double? height;
  double? width;

  ICButtonStyle style = ICButtonStyle();
  bool styled = false;

  ICTextButton();

  void setAction(Map actionArg){
    action = actionArg;
  }

  void setChild(ICText? childArg){
    child = childArg ?? ICText("");
  }

  void setSize({double? heightArg, double? widthArg}){
    height = heightArg;
    width = widthArg;
  }

  void setStyle(ICButtonStyle? buttonStyle){
    if(buttonStyle != null){
      style = buttonStyle;
      styled = true;
    }
  }

  @override
  Widget toFlutter(BuildContext context){
    return TextButton(onPressed: () {onPressed(action);}, style: style.toFlutter(), child: child.toFlutter(context));
  }

  @override
  XmlElement toXml({bool verbose=false}){
    final element = XmlElement(XmlName("textButton"));

    final propertiesElement = XmlElement(XmlName("properties"));

    final childElement = XmlElement(XmlName("child"));
    childElement.children.add(child.toXml(verbose: verbose));
    propertiesElement.children.add(childElement);

    final pressedElement = XmlElement(XmlName("onPressed"));
  
    final type = action?["type"];
    final target = action?["target"];

    final typeElement = type != null ? XmlElement(XmlName("type"),[],[XmlText(type)]) : XmlElement(XmlName("type"),[],[XmlText("")]);
    final targetElement = type != null ? XmlElement(XmlName("target"),[],[XmlText(target)]) : XmlElement(XmlName("target"),[],[XmlText("")]);
      
    final sizeElement = XmlElement(XmlName("size"));
    final heightElement = (height!= null) ? XmlElement(XmlName("height"), [], [XmlText(height.toString())]) : XmlElement(XmlName("height"), [], [XmlText("")]);
    final widthElement = (width!= null) ? XmlElement(XmlName("width"), [], [XmlText(width.toString())]) : XmlElement(XmlName("width"), [], [XmlText("")]);

    final styleElement = style.toXml(verbose:verbose);

    if(verbose==false){
      if(action!=null){
        pressedElement.children.add(typeElement);
        pressedElement.children.add(targetElement);
        propertiesElement.children.add(pressedElement);

        if(height != null){sizeElement.children.add(heightElement);}
        if(width != null){sizeElement.children.add(widthElement);}
        if(sizeElement.children.isNotEmpty){propertiesElement.children.add(sizeElement);}

        if(styled==true && styleElement.children.isNotEmpty){debugPrint("**"); propertiesElement.children.add(styleElement);}
      }
    } else {
      pressedElement.children.add(typeElement);
      pressedElement.children.add(targetElement);
      propertiesElement.children.add(pressedElement);

      sizeElement.children.add(heightElement);
      sizeElement.children.add(widthElement);
      propertiesElement.children.add(sizeElement);
      propertiesElement.children.add(styleElement);
    }

    element.children.add(propertiesElement);

    return element;
  }
}