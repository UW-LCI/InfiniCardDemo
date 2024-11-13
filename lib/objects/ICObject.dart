import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

abstract class ICObject{
  double? width = 10;
  double? height = 10;

  double? top = 10;
  double? left = 10;

  int id = -1;


  Widget toFlutter(BuildContext context);

  XmlElement toXml({bool verbose=false});

  ICObject copyWith({int? newID});
}