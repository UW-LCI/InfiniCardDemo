import 'package:flutter/material.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICText.dart';
import 'package:infinicard_v1/objects/ICObject.dart';


class ICAppBar extends ICObject{
  ICObject? leading;
  ICText? title;
  List<ICObject>? actions;
  double? toolbarHeight;
  double? height;
  ICColor? backgroundColor;
  bool? centerTitle;
  double? leadingWidth;

  ICAppBar();

  void setLeading(ICObject? leadingArg) {
    leading = leadingArg;
  }

  void setTitle(ICText titleArg, {TextStyle? style}) {
    title = titleArg;
  }

  void setActions(List<ICObject> actionsArg) {
    actions = actionsArg;
  }

  void setToolbarHeight(double? heightArg) {
    toolbarHeight = heightArg;
  }

  void setHeight(double? heightArg) {
    height = heightArg;
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
    final element = XmlElement(XmlName('bar'));
    final propertiesElement = XmlElement(XmlName('properties'));

    final bgElement = backgroundColor != null ? XmlElement(XmlName("backgroundColor"),[],[XmlText(backgroundColor!.toColorString())]) : XmlElement(XmlName("backgroundColor"), [], [XmlText("")]);

    final heightElement = height != null ? XmlElement(XmlName("height"), [], [XmlText(height.toString())]) : XmlElement(XmlName("height"), [], [XmlText("")]);
    final toolHeightElement = toolbarHeight != null ? XmlElement(XmlName("toolbarHeight"), [], [XmlText(toolbarHeight.toString())]) : XmlElement(XmlName("toolbarHeight"), [], [XmlText("")]);
    final centerElement = centerTitle != null ? XmlElement(XmlName("centerTitle"), [], [XmlText(centerTitle.toString())]) : XmlElement(XmlName("centerTitle"), [], [XmlText("")]);

    final titleElement = title != null ? title!.toXml(verbose: verbose) : ICText("").toXml(verbose: verbose);
    
    final actionsElement = XmlElement(XmlName("actions"), [], [XmlText("")]);
    final actionElements = actions?.map((action) => action.toXml(verbose: verbose)).toList();

    if(actionElements!=null){actionsElement.children.addAll(actionElements);}

    if(verbose==false){
      if(backgroundColor != null){propertiesElement.children.add(bgElement);}
      if(height != null){propertiesElement.children.add(heightElement);}
      if(toolbarHeight != null){propertiesElement.children.add(toolHeightElement);}
      if(centerTitle != null){propertiesElement.children.add(centerElement);}
      if(title != null){propertiesElement.children.add(titleElement);}
      if(actions != null){propertiesElement.children.add(actionsElement);}
      if(propertiesElement.children.isNotEmpty){element.children.add(propertiesElement);}
    } else {
      propertiesElement.children.add(bgElement);
      propertiesElement.children.add(heightElement);
      propertiesElement.children.add(toolHeightElement);
      propertiesElement.children.add(centerElement);
      propertiesElement.children.add(titleElement);
      propertiesElement.children.add(actionsElement);
      element.children.add(propertiesElement);
    }

    return element;
  }
}
