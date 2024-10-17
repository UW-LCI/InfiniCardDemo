import 'package:flutter/material.dart';
import 'package:infinicard_v1/functions/helpers.dart';
import 'package:infinicard_v1/objects/ICAppBarTheme.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:infinicard_v1/objects/ICTextTheme.dart';
import 'package:infinicard_v1/objects/ICThemeData.dart';
import 'package:xml/xml.dart';

ICThemeData getTheme(String xml, {String? outPath}) {
  final document = XmlDocument.parse(xml);
  final root = document.getElement("root");
  final themeElement = root?.getElement("theme");

  ICThemeData theme = ICThemeData();

  if (themeElement != null) {
    for (XmlElement property in themeElement.childElements) {
      final type = property.name.toString();
      switch (type) {
        case "appBarTheme":
          theme.setAppBarTheme(buildAppBarTheme(property));
          break;
        case "textTheme":
          theme.setTextTheme(buildTextTheme(property));
          break;
        default:
          debugPrint("Tried to build unrecognized theme $type");
      }
    }
  }
  return theme;
}

ICAppBarTheme buildAppBarTheme(XmlElement appBarTheme) {
  ICAppBarTheme theme = ICAppBarTheme();

  final propertiesElement = appBarTheme.getElement("properties");

  if (propertiesElement != null) {
    for (XmlElement property in propertiesElement.childElements) {
      final type = property.name.toString();
      switch (type) {
        case "toolbarTextStyle":
          theme.toolbarTextStyle(getTextStyle(property));
          break;
        case "titleTextStyle":
          theme.titleTextStyle(getTextStyle(property));
          break;
        case "backgroundColor":
          theme.backgroundColor(ICColor(property.innerText));
          break;
        case "foregroundColor":
          theme.foregroundColor(ICColor(property.innerText));
          break;
        default:
          debugPrint("Tried to build unrecognized appBar theme property $type");
      }
    }
  }
  return theme;
}

ICTextTheme buildTextTheme(XmlElement textTheme) {
  ICTextTheme theme = ICTextTheme();

  final propertiesElement = textTheme.getElement("properties");

  if (propertiesElement != null) {
    for (XmlElement property in propertiesElement.childElements) {
      final type = property.name.toString();
      switch (type) {
        case "fontFamily":
          theme.setFontFamily(getString(property));
          break;
        case "color":
          theme.setColor(ICColor(property.innerText));
          break;
        default:
          debugPrint("Tried to build unrecognized Text Theme property $type");
      }
    }
  }
  return theme;
}
