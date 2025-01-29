import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:infinicard_v1/fonts.dart';
import 'package:infinicard_v1/functions/compileXML/compileDrawing.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinicard_v1/objects/ICButtonStyle.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:infinicard_v1/objects/ICIcon.dart';
import 'package:infinicard_v1/objects/ICIconButton.dart';
import 'package:infinicard_v1/objects/ICImage.dart';
import 'package:infinicard_v1/objects/ICText.dart';
import 'package:infinicard_v1/objects/ICTextButton.dart';
import 'package:infinicard_v1/objects/ICTextStyle.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:infinicard_v1/widgets/image_upload.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ImageSelectWidget extends StatefulWidget {
  BoxAction boxAction;

  ImageSelectWidget(this.boxAction, {super.key});

  @override
  State<ImageSelectWidget> createState() => _ImageSelectWidgetState();
}

class _ImageSelectWidgetState extends State<ImageSelectWidget> {
  List<FileSystemEntity>? _images;

  void getImages() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String imageDirectory = '${directory.path}/images';
    Directory imgDir = Directory(imageDirectory);
    setState((){
      _images = imgDir.listSync(recursive: false, followLinks: false);
    });
  }

  void selectImage(File item, InfinicardStateProvider provider){
    ICImage image = widget.boxAction.element as ICImage;
    image.path = item.path;

    provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));
  }

  GridView imgGrid(List<FileSystemEntity>? images, InfinicardStateProvider provider){
    List<GridTile> imgButtons = [];
    if(images != null){
      for(FileSystemEntity each in images){
        if(each is File){
          GridTile imgButton = GridTile(child: InkWell(onTap: (){selectImage(each, provider);}, child:Image.file(each)));
          imgButtons.add(imgButton);
        }
      }
    }
    return GridView.count(crossAxisCount: 2, shrinkWrap: true, children: imgButtons,);
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<InfinicardStateProvider>(context, listen: false);

    getImages();

    ImageUpload imageUpload = ImageUpload(widget.boxAction);
    AutoSizeText header = AutoSizeText(
      "Uploaded Images:",
      maxLines: 1,
    );
    GridView grid = imgGrid(_images, provider);

    

    Scaffold body = Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [imageUpload, Expanded(child: header), SingleChildScrollView(child: SizedBox(height: 150, child:grid))],
      ),
    );

    return Padding(
        padding: EdgeInsets.only(top: 10),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade700),
                borderRadius: BorderRadius.all(Radius.circular(18))),
            width: 200,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(width: 200, height: 240, child: body))));
  }
}
