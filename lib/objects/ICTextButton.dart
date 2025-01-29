import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICText.dart';
import 'package:infinicard_v1/objects/ICButtonStyle.dart';
import 'package:infinicard_v1/objects/ICObject.dart';
import 'package:infinicard_v1/functions/helpers.dart';

class ICTextButton extends ICObject{
  Map<String?, String?> action = {"type":null, "target":null};
  ICText child = ICText("Button");

  @override
  double? height;
  @override
  double? width;

  @override
  double? top;
  @override
  double? left;

  int id = -1;

  ICButtonStyle style = ICButtonStyle();
  bool styled = false;

  ICTextButton();

  void setAction(Map<String?,String?> actionArg){
    action = actionArg;
  }

  void setChild(ICText? childArg){
    child = childArg ?? ICText("");
  }

  void setSize({double? heightArg, double? widthArg}){
    height = heightArg;
    width = widthArg;
    if(heightArg != null && widthArg !=null){
      child.setSize(heightArg: height!/2, widthArg: width!/2);
    }
  }

  void setLocation({double? topArg, double? leftArg}){
    top = topArg;
    left = leftArg;
  }

  void setStyle(ICButtonStyle? buttonStyle){
    if(buttonStyle != null){
      style = buttonStyle;
      styled = true;
    }
  }

  @override
  ICTextButton copyWith({int? newID}){
    ICTextButton newButton = ICTextButton();
    newButton.id = newID ?? -1;

    newButton.action = Map.from(action);

    newButton.height = height;
    newButton.width = width;

    newButton.top = top;
    newButton.left = left;

    newButton.child = child.copyWith(newID: UniqueKey().hashCode);
    newButton.style = style;
    newButton.styled = styled;

    return newButton;
  }

  @override
  Widget toFlutter(BuildContext context){
    return TextButton(onPressed: () {onPressed(action, context);}, style: style.toFlutter(), child: child.toFlutter(context));
  }

  @override
  XmlElement toXml({bool verbose=false}){
    final element = XmlElement(XmlName('textButton'),[XmlAttribute(XmlName("id"), id.toString())],[]);

    final propertiesElement = XmlElement(XmlName("properties"));

    final childElement = XmlElement(XmlName("child"));
    childElement.children.add(child.toXml(verbose: verbose));
    propertiesElement.children.add(childElement);

    final pressedElement = XmlElement(XmlName("onPressed"));
  
    final type = action["type"];
    final target = action["target"];

    final typeElement = type != null ? XmlElement(XmlName("type"),[],[XmlText(type)]) : XmlElement(XmlName("type"),[],[XmlText("")]);
    final targetElement = target != null ? XmlElement(XmlName("target"),[],[XmlText(target)]) : XmlElement(XmlName("target"),[],[XmlText("")]);
      
    final sizeElement = XmlElement(XmlName("size"));
    final heightElement = (height!= null) ? XmlElement(XmlName("height"), [], [XmlText(height.toString())]) : XmlElement(XmlName("height"), [], [XmlText("")]);
    final widthElement = (width!= null) ? XmlElement(XmlName("width"), [], [XmlText(width.toString())]) : XmlElement(XmlName("width"), [], [XmlText("")]);

    final locationElement = XmlElement(XmlName("location"));
    final topElement = (height!= null) ? XmlElement(XmlName("top"), [], [XmlText(top.toString())]) : XmlElement(XmlName("top"), [], [XmlText("")]);
    final leftElement = (width!= null) ? XmlElement(XmlName("left"), [], [XmlText(left.toString())]) : XmlElement(XmlName("left"), [], [XmlText("")]);


    final styleElement = style.toXml(verbose:verbose);

    if(verbose==false){
      if(type!=null && target!=null){
        pressedElement.children.add(typeElement);
        pressedElement.children.add(targetElement);
        propertiesElement.children.add(pressedElement);

        if(height != null){sizeElement.children.add(heightElement);}
        if(width != null){sizeElement.children.add(widthElement);}
        if(sizeElement.children.isNotEmpty){propertiesElement.children.add(sizeElement);}

        if(top != null){locationElement.children.add(topElement);}
        if(left != null){locationElement.children.add(leftElement);}
        if(locationElement.children.isNotEmpty){propertiesElement.children.add(locationElement);}

        if(styled==true && styleElement.children.isNotEmpty){debugPrint("**"); propertiesElement.children.add(styleElement);}
      }
    } else {
      pressedElement.children.add(typeElement);
      pressedElement.children.add(targetElement);
      propertiesElement.children.add(pressedElement);

      sizeElement.children.add(heightElement);
      sizeElement.children.add(widthElement);
      propertiesElement.children.add(sizeElement);

      locationElement.children.add(topElement);
      locationElement.children.add(leftElement);
      propertiesElement.children.add(locationElement);

      propertiesElement.children.add(styleElement);
    }

    element.children.add(propertiesElement);

    return element;
  }
}