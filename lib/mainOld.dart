// import 'package:flutter/material.dart';
// import 'package:infinicard_v1/functions/buildApp.dart';
// import 'dart:io';


// void main() {
  
//   runApp(MainApp());
// }

// class MainApp extends StatelessWidget {
//   MainApp({super.key});

//   String getXML(String filename, String path) {
//     final File file = File('$path/$filename');
//     final xml = file.readAsStringSync();
//     return xml;
//   }

//   @override
//   Widget build(BuildContext context) {
//     //[temp] change path to app document directory path
//     String path = "/Users/samhross/Library/Containers/com.example.infinicardV1/Data/Documents";
//     String uiXML = getXML('spec.xml', path);

//     return infinicardApp(uiXML);
//   }
// }
