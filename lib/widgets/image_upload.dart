import 'dart:io';

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
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class ImageUpload extends StatefulWidget {
  BoxAction boxAction;

  ImageUpload(this.boxAction, {super.key});

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {    
  final _fileExtensionController = TextEditingController();
  String? _extension;

  FilePickerResult? result;

  @override
  void initState() {
    super.initState();
    _fileExtensionController
        .addListener(() => _extension = _fileExtensionController.text);
  }

  void getFile(InfinicardStateProvider provider) async {
    result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result!.files.single.path!);
      String name = result!.files.single.name;
      
      Directory directory = await getApplicationDocumentsDirectory();
      String path = directory.path;

      File uploadedImage = await file.copy('$path/images/$name');

      ICImage image = widget.boxAction.element as ICImage;
      image.path = uploadedImage.path;

      provider.updateSource(compileDrawing(provider.getActiveActions(), provider.icApp));

    } else {
      // User canceled the picker
  }
  
}

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<InfinicardStateProvider>(context, listen: false);

    void chooseFile(InfinicardStateProvider provider){
      getFile(provider);
    }

    return IconButton(icon:Icon(Icons.file_upload_outlined), onPressed: (){chooseFile(provider);},);
  }
}
