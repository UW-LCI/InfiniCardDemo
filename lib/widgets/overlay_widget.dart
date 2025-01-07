import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/draw_actions.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';
import 'package:infinicard_v1/models/draw_actions/delete_action.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:infinicard_v1/widgets/image_select_widget.dart';
import 'package:infinicard_v1/widgets/image_upload.dart';
import 'package:infinicard_v1/widgets/input_widget.dart';
import 'package:infinicard_v1/widgets/style_widget.dart';
import 'package:provider/provider.dart';

class OverlayWidget extends StatefulWidget {
  BoxAction boxAction;

  OverlayWidget(this.boxAction, {super.key});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  bool _offstage = true;
  bool _inputOffstage = true;
  bool _uploadOffstage = true;
  String type = "";

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<InfinicardStateProvider>(context, listen: false);

    final List<DropdownMenuEntry> dropdownElements = [
      const DropdownMenuEntry(value: 'textButton', label: 'textButton'),
      const DropdownMenuEntry(value: 'text', label: 'text'),
      const DropdownMenuEntry(value: 'image', label: 'image'),
      const DropdownMenuEntry(value: 'row', label: 'row'),
      const DropdownMenuEntry(value: 'column', label: 'column'),
      const DropdownMenuEntry(value: 'iconButton', label: 'iconButton'),
      const DropdownMenuEntry(value: 'bar', label: 'bar'),
      const DropdownMenuEntry(value: 'icon', label: 'icon')
    ];

    Offstage stylePopup =
        Offstage(offstage: _offstage, child: StyleWidget(widget.boxAction));
    type = widget.boxAction.elementName;

    Offstage inputPopup = Offstage(
        offstage: _inputOffstage, child: InputWidget(widget.boxAction));

    Offstage uploadPopup = Offstage(
        offstage: _uploadOffstage, child: ImageSelectWidget(widget.boxAction));

    DropdownMenu menu = DropdownMenu(
        dropdownMenuEntries: dropdownElements,
        initialSelection: type,
        menuStyle: const MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white)),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                borderSide: BorderSide(color: Colors.grey.shade700))),
        onSelected: (value) {
          provider.updateDropdown(value, widget.boxAction);
          setState(() {
            type = widget.boxAction.elementName;
          });
          _offstage = true;
        });
    IconButton styleBox = IconButton(
        onPressed: () {
          setState(() {
            _offstage = !_offstage;
            _inputOffstage = true;
            _uploadOffstage = true;
          });
        },
        icon: Icon(Icons.palette));
    IconButton deleteBox = IconButton(
        onPressed: () {
          provider.delete(widget.boxAction);
        },
        icon: const Icon(Icons.delete));
    IconButton duplicateBox = IconButton(
        onPressed: () {
          provider.duplicate(widget.boxAction);
        },
        icon: const Icon(Icons.copy));
    IconButton inputBox = IconButton(
        onPressed: () {
          setState(() {
            _inputOffstage = !_inputOffstage;
            _uploadOffstage = true;
            _offstage = true;
          });
        },
        icon: const Icon(Icons.text_snippet_outlined));
    IconButton imageUploadBox = IconButton(
        onPressed: () {
          setState(() {
            _uploadOffstage = !_uploadOffstage;
            _inputOffstage = true;
            _offstage = true;
          });
        },
        icon: const Icon(Icons.add_photo_alternate_outlined));

    List<Widget> options = [];
    switch (type) {
      case "text":
        options = [menu, styleBox, inputBox, duplicateBox, deleteBox];
        break;
      case "textButton":
        options = [menu, styleBox, inputBox, duplicateBox, deleteBox];
        break;
      case "icon":
        options = [menu, styleBox, duplicateBox, deleteBox];
        break;
      case "iconButton":
        options = [menu, styleBox, duplicateBox, deleteBox];
        break;
      case "image":
        options = [menu, styleBox, imageUploadBox, duplicateBox, deleteBox];
        break;
      case "bar":
        options = [menu, styleBox, duplicateBox, deleteBox];
        break;
      case "row":
        options = [menu, duplicateBox, deleteBox];
        break;
      case "column":
        options = [menu, duplicateBox, deleteBox];
        break;
      default:
        options = [menu, duplicateBox, deleteBox];
    }

    return Container(
        alignment: Alignment.bottomCenter,
        child:
            Column(children: [Row(children: options), stylePopup, inputPopup, uploadPopup]));
  }
}
