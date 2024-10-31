import 'package:flutter/material.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICText.dart';
import 'package:infinicard_v1/objects/ICObject.dart';


class ICAppBar extends ICObject{
  ICObject? leading;
  ICObject? title;
  List<ICObject>? actions;
  double? toolbarHeight;

  double? height;
  double? width;
  
  double? top;
  double? left;

  ICColor? backgroundColor;
  bool? centerTitle;
  double? leadingWidth;

  int id = -1;

  ICAppBar();

  void setLeading(ICObject? leadingArg) {
    leading = leadingArg;
  }

  void setTitle(ICObject titleArg, {TextStyle? style}) {
    title = titleArg;
  }

  void setActions(List<ICObject> actionsArg) {
    actions = actionsArg;
  }

  void setToolbarHeight(double? heightArg) {
    toolbarHeight = heightArg;
  }

  void setSize({double? heightArg, double? widthArg}){
    height = heightArg;
    width = widthArg;
  }

  void setLocation({double? topArg, double? leftArg}){
    top = topArg;
    left = leftArg;
  }

  void setBackgroundColor(ICColor colorArg) {
    backgroundColor = colorArg;
  }

  void setCenterTitle(bool? centerTitleArg) {
    centerTitle = centerTitleArg;
  }

  void setLeadingWidth(double widthArg) {
    leadingWidth = widthArg;
  }

  @override
  Widget toFlutter(BuildContext context) {
    var flutterActions = actions?.map((action) => action.toFlutter(context)).toList();
    return AppBar(
        leading: leading?.toFlutter(context),
        title: title?.toFlutter(context),
        actions: flutterActions,
        backgroundColor: backgroundColor?.toFlutter(),
        centerTitle: centerTitle,
        toolbarHeight: toolbarHeight,
        leadingWidth: leadingWidth);
  }

  @override
  XmlElement toXml({bool verbose=false}){
    final element = XmlElement(XmlName('bar'),[XmlAttribute(XmlName("id"), id.toString())],[]);

    final propertiesElement = XmlElement(XmlName('properties'));

    final bgElement = backgroundColor != null ? XmlElement(XmlName("backgroundColor"),[],[XmlText(backgroundColor!.toColorString())]) : XmlElement(XmlName("backgroundColor"), [], [XmlText("")]);

    final sizeElement = XmlElement(XmlName("size"));
    final heightElement = (height!= null) ? XmlElement(XmlName("height"), [], [XmlText(height.toString())]) : XmlElement(XmlName("height"), [], [XmlText("")]);
    final widthElement = (width!= null) ? XmlElement(XmlName("width"), [], [XmlText(width.toString())]) : XmlElement(XmlName("width"), [], [XmlText("")]);

    final locationElement = XmlElement(XmlName("location"));
    final topElement = (height!= null) ? XmlElement(XmlName("top"), [], [XmlText(top.toString())]) : XmlElement(XmlName("top"), [], [XmlText("")]);
    final leftElement = (width!= null) ? XmlElement(XmlName("left"), [], [XmlText(left.toString())]) : XmlElement(XmlName("left"), [], [XmlText("")]);

    final toolHeightElement = toolbarHeight != null ? XmlElement(XmlName("toolbarHeight"), [], [XmlText(toolbarHeight.toString())]) : XmlElement(XmlName("toolbarHeight"), [], [XmlText("")]);
    final centerElement = centerTitle != null ? XmlElement(XmlName("centerTitle"), [], [XmlText(centerTitle.toString())]) : XmlElement(XmlName("centerTitle"), [], [XmlText("")]);

    final titleElement = title != null ? title!.toXml(verbose: verbose) : ICText("").toXml(verbose: verbose);
    
    final actionsElement = XmlElement(XmlName("actions"), [], [XmlText("")]);
    final actionElements = actions?.map((action) => action.toXml(verbose: verbose)).toList();

    if(actionElements!=null){actionsElement.children.addAll(actionElements);}

    if(verbose==false){
      if(backgroundColor != null){propertiesElement.children.add(bgElement);}

      if(height != null){sizeElement.children.add(heightElement);}
      if(width != null){sizeElement.children.add(widthElement);}
      if(sizeElement.children.isNotEmpty){propertiesElement.children.add(sizeElement);}

      if(top != null){locationElement.children.add(topElement);}
      if(left != null){locationElement.children.add(leftElement);}
      if(locationElement.children.isNotEmpty){propertiesElement.children.add(locationElement);}

      if(toolbarHeight != null){propertiesElement.children.add(toolHeightElement);}
      if(centerTitle != null){propertiesElement.children.add(centerElement);}
      if(title != null){propertiesElement.children.add(titleElement);}
      if(actions != null){propertiesElement.children.add(actionsElement);}
      if(propertiesElement.children.isNotEmpty){element.children.add(propertiesElement);}
    } else {
      propertiesElement.children.add(bgElement);

      sizeElement.children.add(heightElement);
      sizeElement.children.add(widthElement);
      propertiesElement.children.add(sizeElement);

      locationElement.children.add(topElement);
      locationElement.children.add(leftElement);
      propertiesElement.children.add(locationElement);

      propertiesElement.children.add(toolHeightElement);
      propertiesElement.children.add(centerElement);
      propertiesElement.children.add(titleElement);
      propertiesElement.children.add(actionsElement);
      element.children.add(propertiesElement);
    }

    return element;
  }
}
