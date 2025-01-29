import 'package:flutter/material.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:provider/provider.dart';

class FileNavigator extends StatefulWidget {
  const FileNavigator({super.key});

  @override
  State<FileNavigator> createState() => _FileNavigatorState();
}

class _FileNavigatorState extends State<FileNavigator> {
  String selectedView = "draw";
  @override
  Widget build(BuildContext context) {
    
    final provider =
        Provider.of<InfinicardStateProvider>(context, listen: false);
    return Scaffold(
        body: Column(children: [
          Container(
              height: 40,
              width: double.infinity,
              color: selectedView == "draw" ? Colors.white : Colors.purple[50],
              child: GestureDetector(
                  onTap: () {
                    provider.updateActiveViews("draw", "open");
                    setState(() {
                      selectedView = "draw";
                    });
                  },
                  child: Padding(padding: EdgeInsets.all(10), child:Text("Canvas")))),
          Container(
              height: 40,
              width: double.infinity,
              color: selectedView == "render" ? Colors.white : Colors.purple[50],
              child: GestureDetector(
                  onTap: () {
                    provider.updateActiveViews("render", "open");
                    setState(() {
                      selectedView = "render";
                    });
                  },
                  child: Padding(padding: EdgeInsets.all(10), child:Text("Render")))),
          Container(
              height: 40,
              width: double.infinity,
              color: selectedView == "xml" ? Colors.white : Colors.purple[50],
              child: GestureDetector(
                  onTap: () {
                    provider.updateActiveViews("xml", "open");
                    setState(() {
                      selectedView = "xml";
                    });
                  },
                  child: Padding(padding: EdgeInsets.all(10), child:Text("XML"))))
        ]));
  }
}
