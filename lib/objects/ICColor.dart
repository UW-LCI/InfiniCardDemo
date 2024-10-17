import 'package:flutter/material.dart';

import 'package:infinicard_v1/colors.dart';

class ICColor {
  String inputColor;
  RegExp hexColor = RegExp(r'^0x([0-9a-fA-F]{8})$');

  bool hexMatch = false;
  String? color;
  String? colorName;

  ICColor(this.inputColor){
    if(inputColor!=""){
      String colorString = inputColor.toLowerCase().replaceAll(' ', '');
      hexMatch = hexColor.hasMatch(colorString);
      if(hexMatch==true){
        color = colorString;
        colorName = supportedHex.containsKey(colorString) ? supportedHex[colorString] : colorString;
      } else {
        colorName = supportedColors.containsKey(colorString) ? colorString : null;
        color = colorName != null ? supportedColors[colorName] : null;
      }
    }
  }

  Color? toFlutter(){
    if(color!=null){
      return Color(int.parse(color as String));
    }
    return null;
  }

  String toColorString(){
    if(inputColor != ""){
      return colorName as String;
    }
    return "";
  }
}