import 'package:flutter/material.dart';
import 'package:infinicard_v1/providers/infinicard_state_provider.dart';
import 'package:provider/provider.dart';

class DesignWindow extends StatefulWidget {
  const DesignWindow({super.key, required this.view, required this.type});
  final Widget view;
  final String type;

  @override
  State<DesignWindow> createState() => _DesignWindowState();
}

class _DesignWindowState extends State<DesignWindow> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InfinicardStateProvider>(context, listen: false);
    final String type = widget.type;
    return Scaffold(
      appBar: AppBar(actions: [IconButton(onPressed: (){provider.updateActiveViews(type, "close");}, icon: const Icon(Icons.close))],),
      backgroundColor: Colors.white,
      body: widget.view
    );
  }
}