import 'package:flutter/material.dart';

class AlexandrioBookmark extends StatefulWidget {
  final double posX;
  final double posY;
  final int id;
  final Function status;
  final bool isNote;
  final String note;

  const AlexandrioBookmark({Key? key, required this.posX, required this.posY, required this.id, required this.status, required this.isNote, required this.note}) : super(key: key);

  @override
  State<AlexandrioBookmark> createState() => _AlexandrioIconState();
}

class _AlexandrioIconState extends State<AlexandrioBookmark> {
  @override
  Widget build(BuildContext context) {
    if (widget.isNote == false) {
      return Positioned(
        left: widget.posX,
        top: widget.posY,
        child: IconButton(
          icon: const Icon(Icons.star),
          color: Colors.red,
          onPressed: () => widget.status(),
        ),
      );
    } else {
      return Positioned(
        left: widget.posX,
        top: widget.posY,
        child: IconButton(
          tooltip: widget.note,
          icon: const Icon(Icons.notes),
          color: Colors.blue,
          onPressed: () {
            widget.status();
          },
        ),
      );
    }
  }
}
