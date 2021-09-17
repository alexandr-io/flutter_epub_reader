import 'package:flutter/material.dart';

class AlexandrioBookmark extends StatefulWidget {
  final String? pos;
  final int id;
  final Function status;
  final Function redirect;
  final bool isNote;
  final String note;
  final String dataId;

  const AlexandrioBookmark({
    Key? key,
    required this.pos,
    required this.id,
    required this.status,
    required this.redirect,
    required this.isNote,
    required this.note,
    required this.dataId
  }) : super(key: key);

  @override
  State<AlexandrioBookmark> createState() => _AlexandrioIconState();
}

class _AlexandrioIconState extends State<AlexandrioBookmark> {
  @override
  Widget build(BuildContext context) {
    if (widget.isNote == false) {
      // return IconButton(
      //   icon: const Icon(Icons.bookmark),
      //   color: Colors.red,
      //   onPressed: () => { widget.status() }
      // );
      return Row(
          children: <Widget>[
            const Spacer(),
            const Expanded(
              child: Center(
                child: Icon(Icons.bookmark),
              )
            ),
            Expanded(
              child: Center(
                child: IconButton(
                  onPressed: () => { widget.redirect() },
                  icon: const Icon(Icons.arrow_right_alt_rounded)
                )
              ),
            ),
            Expanded(
              child: Center(
                child: IconButton(
                  onPressed: () => widget.status(),
                  color: Colors.red,
                  icon: const Icon(Icons.highlight_remove_sharp)
                )
              )
            )
          ],
        );
    } else {
      // return IconButton(
      //   tooltip: widget.note,
      //   icon: const Icon(Icons.messenger),
      //   color: Colors.red,
      //   onPressed: () => { widget.status() },
      // );    
      return Row(
          children: <Widget>[
            const Spacer(),
            Expanded(
              child: Center(
                child: Tooltip(
                  message: widget.note,
                  child: const Icon(Icons.messenger),
                ) 
              )
            ),
            Expanded(
              child: Center(
                child: IconButton(
                  onPressed: () => { widget.redirect() },
                  icon: const Icon(Icons.arrow_right_alt_rounded)
                )
              ),
            ),
            Expanded(
              child: Center(
                child: IconButton(
                  onPressed: () => widget.status(),
                  color: Colors.red,
                  icon: const Icon(Icons.highlight_remove_sharp)
                )
              )
            )
          ],
        );  
    }
  }
}
