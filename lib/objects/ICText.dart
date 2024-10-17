import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICTextStyle.dart';
import 'package:infinicard_v1/objects/ICObject.dart';

class ICText extends ICObject{
  String data = "";
  ICTextStyle textStyle = ICTextStyle();
  TextAlign textAlign = TextAlign.left;
  bool styled = false;

  double? height;
  double? width;
  
  ICText(this.data);

  void setStyle(ICTextStyle? style) {
    textStyle = style ?? ICTextStyle();
    styled = style != null ? true : false;
  }

  void setAlign(TextAlign align) {
    textAlign = align;
  }

  void setSize({double? heightArg, double? widthArg}){
    height = heightArg;
    width = widthArg;
  }

  // ICTextStyle defaultStyle(BuildContext context) {
  //   return ICTextStyle();
  // }

  @override
  Widget toFlutter(BuildContext context) { //add toXML function
    return Text(data, style: textStyle.toFlutter(context: context), textAlign: textAlign);
  }

  @override
  XmlElement toXml({bool verbose=false}){
    final element = XmlElement(XmlName("text"));
    final propertiesElement = XmlElement(XmlName("properties"));

    final textElement = XmlElement(XmlName("data"),[],[XmlText(data)]);
    final textStyleElement = textStyle.toXml(verbose: verbose);

    final sizeElement = XmlElement(XmlName("size"));
    final heightElement = (height!= null) ? XmlElement(XmlName("height"), [], [XmlText(height.toString())]) : XmlElement(XmlName("height"), [], [XmlText("")]);
    final widthElement = (width!= null) ? XmlElement(XmlName("width"), [], [XmlText(width.toString())]) : XmlElement(XmlName("width"), [], [XmlText("")]);

    element.children.add(textElement);
    if(styled){propertiesElement.children.add(textStyleElement);}
    
    if(verbose==false){
      if(height != null){sizeElement.children.add(heightElement);}
      if(width != null){sizeElement.children.add(widthElement);}
      if(sizeElement.children.isNotEmpty){propertiesElement.children.add(sizeElement);}
      if(propertiesElement.children.isNotEmpty){element.children.add(propertiesElement);}
    }else{
      sizeElement.children.add(heightElement);
      sizeElement.children.add(widthElement);
      propertiesElement.children.add(sizeElement);
      element.children.add(propertiesElement);
    }
    
    return element;
  }
}
