
import 'package:flutter/material.dart';
import 'package:infinicard_v1/functions/buildApp.dart';

class InfinicardStateProvider extends ChangeNotifier{
  String source = "";
  infinicardApp icApp = infinicardApp("<root></root>");
  Widget widget = const Placeholder();

  void updateSource(String newSource){
    try{
      final infinicardApp newICApp = _compileInfinicardXML(newSource);
      final Widget newWidget = newICApp.toFlutter();
      icApp = newICApp;
      widget = newWidget;
      source = newSource;
      notifyListeners();
    } on Exception {
      // do something with this here
    }
  }

  String retrieveSource({bool verbose = false}){
    final appXML = icApp.toXml(verbose: verbose);
    return appXML.toXmlString(pretty:true);
  }

  infinicardApp _compileInfinicardXML(source){
    return infinicardApp(source);
  }

}

