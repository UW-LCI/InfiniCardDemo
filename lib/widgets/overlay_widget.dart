import 'package:flutter/material.dart';
import 'package:infinicard_v1/models/draw_actions.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';
import 'package:infinicard_v1/models/draw_actions/delete_action.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
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

    Offstage stylePopup = Offstage(offstage: _offstage, child: StyleWidget(widget.boxAction));

    DropdownMenu menu = DropdownMenu(
        dropdownMenuEntries: dropdownElements,
        initialSelection: widget.boxAction.elementName,
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
        });
    IconButton styleBox =
        IconButton(onPressed: () {setState(() {
          _offstage = !_offstage;
        });}, icon: Icon(Icons.palette));
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
    return Container(alignment: Alignment.bottomCenter,child:Column(children:[Row(children: [menu, styleBox, deleteBox, duplicateBox]),stylePopup]));
  }
}
