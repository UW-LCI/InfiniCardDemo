import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../widgets/canvas_widget.dart';

class SourceEditor extends StatefulWidget {
  const SourceEditor({super.key});

  @override
  State<SourceEditor> createState() => _SourceEditorState();
}

class _SourceEditorState extends State<SourceEditor> {
  String currentSourceString = '';
  final _textController = TextEditingController();
  final _nameController = TextEditingController();
  List<DropdownMenuEntry> entries = [];
  Box? uiDB;
  Uuid uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    currentSourceString = _getInfinicardStateProvider(context).source;
    initHive().then((value) {
      uiDB = value;
      loadItems(uiDB);
    });
  }

  Future<Box> initHive() async {
    WidgetsFlutterBinding.ensureInitialized();
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.toString());
    return await Hive.openBox("UI");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Column(
          children: [
            Row(children: [
              TextButton(
                  onPressed: () {
                    _textController.text = recognize();
                    _compileSource(context, _textController.text);
                  },
                  child: const Text("Compile from Drawing")),
              TextButton(
                  onPressed: () {
                    _textController.text = _getSource(context, true);
                    _compileSource(context, _textController.text);
                  },
                  child: const Text("Expand")),
              TextButton(
                  onPressed: () {
                    _textController.text = _getSource(context, false);
                    _compileSource(context, _textController.text);
                  },
                  child: const Text("Collapse")),
              TextButton(
                  onPressed: () {
                    _textController.text = "<root></root>";
                    _compileSource(context, _textController.text);
                  },
                  child: const Text("Reset")),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.multiline,
                  minLines: 1, //Normal textInputField will be displayed
                  maxLines: null,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "filename"),
                ),
              ),
              TextButton(
                  onPressed: () {
                    if (_nameController.text != "") {
                      uiDB?.put(_nameController.text, _textController.text);
                      loadItems(uiDB);
                    }
                  },
                  child: const Text("Save")),
              TextButton(
                  onPressed: () {
                    if (_nameController.text != "") {
                      uiDB?.delete(_nameController.text);
                      loadItems(uiDB);
                    }
                  },
                  child: const Text("Delete")),
              TextButton(
                  onPressed: () {
                    var keys = uiDB?.keys;
                    if (keys!=null) {
                      uiDB?.deleteAll(keys);
                      loadItems(uiDB);
                      _textController.text = "<root></root>";
                      _compileSource(context, _textController.text);
                    }
                  },
                  child: const Text("Delete All")),
              DropdownMenu(
                dropdownMenuEntries: entries,
                onSelected: (label) {
                  debugPrint(label);
                  String? loadedText = uiDB?.get(label);
                  _textController.text = loadedText!; // TODO: handle case
                                  _compileSource(context, _textController.text);
                },
              )
            ]),
            TextFormField(
              controller: _textController,
              initialValue: null,
              keyboardType: TextInputType.multiline,
              minLines: 1, //Normal textInputField will be displayed
              maxLines: null,
              onChanged: (s) => _compileSource(context, s),
            )
          ],
        )));
  }

  void loadItems(Box? uiEntries) {
    List<DropdownMenuEntry> items = [];
    if (uiEntries != null) {
      for (var ui in uiEntries.keys) {
        items.add(DropdownMenuEntry(value: ui, label: ui));
      }
    }
    setState(() {
      entries = items;
    });
  }

  void _compileSource(BuildContext context, String newSource) {
    final provider = _getInfinicardStateProvider(context);
    provider.updateSource(newSource);
  }

  String _getSource(BuildContext context, bool verbose) {
    final provider = _getInfinicardStateProvider(context);
    return provider.retrieveSource(verbose:verbose);
  }

  InfinicardStateProvider _getInfinicardStateProvider(context) {
    return Provider.of<InfinicardStateProvider>(context, listen: false);
  }
}
