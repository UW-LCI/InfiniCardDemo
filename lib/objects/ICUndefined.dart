import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:infinicard_v1/objects/ICTextStyle.dart';
import 'package:infinicard_v1/objects/ICObject.dart';

class ICUndefined extends ICObject{

  @override
  double? height = 10;
  @override
  double? width = 10;
  
  @override
  double? top = 10;
  @override
  double? left = 10;

  @override
  int id = -1;

  ICUndefined();

  @override
  ICUndefined copyWith({int? newID}) {
    ICUndefined newUndefined = ICUndefined();
    newUndefined.id = newID ?? -1;

    newUndefined.height = height;
    newUndefined.width = width;

    newUndefined.top = top;
    newUndefined.left = left;

    return newUndefined;
  }

  @override
  Widget toFlutter(BuildContext context) { //add toXML function
    return SizedBox(width: width, height: height, child:null);
  }

  @override
  XmlElement toXml({bool verbose=false}){
    final element = XmlElement(XmlName('undefined'),[XmlAttribute(XmlName("id"), id.toString())],[]);
    final propertiesElement = XmlElement(XmlName("properties"));

    final sizeElement = XmlElement(XmlName("size"));
    final heightElement = (height!= null) ? XmlElement(XmlName("height"), [], [XmlText(height.toString())]) : XmlElement(XmlName("height"), [], [XmlText("")]);
    final widthElement = (width!= null) ? XmlElement(XmlName("width"), [], [XmlText(width.toString())]) : XmlElement(XmlName("width"), [], [XmlText("")]);

    final locationElement = XmlElement(XmlName("location"));
    final topElement = (height!= null) ? XmlElement(XmlName("top"), [], [XmlText(top.toString())]) : XmlElement(XmlName("top"), [], [XmlText("")]);
    final leftElement = (width!= null) ? XmlElement(XmlName("left"), [], [XmlText(left.toString())]) : XmlElement(XmlName("left"), [], [XmlText("")]);

    if(verbose==false){
      if(height != null){sizeElement.children.add(heightElement);}
      if(width != null){sizeElement.children.add(widthElement);}
      if(sizeElement.children.isNotEmpty){propertiesElement.children.add(sizeElement);}

      if(top != null){locationElement.children.add(topElement);}
      if(left != null){locationElement.children.add(leftElement);}
      if(locationElement.children.isNotEmpty){propertiesElement.children.add(locationElement);}

      if(propertiesElement.children.isNotEmpty){element.children.add(propertiesElement);}
    }else{
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
}
