import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:infinicard_v1/objects/ICTextStyle.dart';
import 'package:infinicard_v1/objects/ICObject.dart';

class ICText extends ICObject {
  String data = "";
  ICTextStyle textStyle = ICTextStyle();
  TextAlign textAlign = TextAlign.left;
  bool styled = false;

  @override
  double? height = 10;
  @override
  double? width = 10;

  @override
  double? top = 10;
  @override
  double? left = 10;

  int id = -1;

  ICText(this.data);

  void setStyle(ICTextStyle? style) {
    textStyle = style ?? ICTextStyle();
    styled = style != null ? true : false;
  }

  void setAlign(TextAlign align) {
    textAlign = align;
  }

  void setSize({double? heightArg, double? widthArg}) {
    height = heightArg;
    width = widthArg;
  }

  void setLocation({double? topArg, double? leftArg}) {
    top = topArg;
    left = leftArg;
  }

  @override
  ICText copyWith({int? newID}) {
    ICText newText = ICText(data);
    newText.id = newID ?? -1;

    newText.textStyle = textStyle;
    newText.styled = styled;
    newText.textAlign = textAlign;

    newText.height = height;
    newText.width = width;

    newText.top = top;
    newText.left = left;

    return newText;
  }

  @override
  Widget toFlutter(BuildContext context) {

    return SizedBox(
        width: width,
        height: height,
        child: AutoSizeText(data,
                style: textStyle.toFlutter(context: context),
                minFontSize: 0,
                maxFontSize: double.infinity,
                softWrap: true,
                textScaleFactor: 1,
                overflow: TextOverflow.visible));
  }

  @override
  XmlElement toXml({bool verbose = false}) {
    final element = XmlElement(
        XmlName('text'), [XmlAttribute(XmlName("id"), id.toString())], []);
    final propertiesElement = XmlElement(XmlName("properties"));

    final textElement = XmlElement(XmlName("data"), [], [XmlText(data)]);
    final textStyleElement = textStyle.toXml(verbose: verbose);

    final sizeElement = XmlElement(XmlName("size"));
    final heightElement = (height != null)
        ? XmlElement(XmlName("height"), [], [XmlText(height.toString())])
        : XmlElement(XmlName("height"), [], [XmlText("")]);
    final widthElement = (width != null)
        ? XmlElement(XmlName("width"), [], [XmlText(width.toString())])
        : XmlElement(XmlName("width"), [], [XmlText("")]);

    final locationElement = XmlElement(XmlName("location"));
    final topElement = (height != null)
        ? XmlElement(XmlName("top"), [], [XmlText(top.toString())])
        : XmlElement(XmlName("top"), [], [XmlText("")]);
    final leftElement = (width != null)
        ? XmlElement(XmlName("left"), [], [XmlText(left.toString())])
        : XmlElement(XmlName("left"), [], [XmlText("")]);

    element.children.add(textElement);
    if (styled) {
      propertiesElement.children.add(textStyleElement);
    }

    if (verbose == false) {
      if (height != null) {
        sizeElement.children.add(heightElement);
      }
      if (width != null) {
        sizeElement.children.add(widthElement);
      }
      if (sizeElement.children.isNotEmpty) {
        propertiesElement.children.add(sizeElement);
      }

      if (top != null) {
        locationElement.children.add(topElement);
      }
      if (left != null) {
        locationElement.children.add(leftElement);
      }
      if (locationElement.children.isNotEmpty) {
        propertiesElement.children.add(locationElement);
      }

      if (propertiesElement.children.isNotEmpty) {
        element.children.add(propertiesElement);
      }
    } else {
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
