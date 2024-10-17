import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

abstract class ICObject{
  Widget toFlutter(BuildContext context);

  XmlElement toXml({bool verbose=false});
}