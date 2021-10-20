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

  void _showText(String text) {
    showDialog(context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Your comment'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => { Navigator.pop(context) },
              child: const Text('Close'),
            )
          ],
        );
      }
    );
  }

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
            //const Spacer(),
            const Expanded(
              child: Center(
                child: Icon(Icons.bookmark),
              )
            ),
            Expanded(
              child: Center(
                child: IconButton(
                  onPressed: () => { widget.redirect() },
                  icon: const Icon(Icons.fmd_good_rounded ),
                  tooltip: 'Go to location',
                )
              ),
            ),
            Expanded(
              child: Center(
                child: IconButton(
                  onPressed: () => widget.status(),
                  color: Colors.red,
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete'
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
            Expanded(
              child: Center(
                child: IconButton(
                  onPressed: () => _showText(widget.note),
                  icon: const Icon(Icons.messenger),
                  tooltip: 'Show note',
                )
              )
            ),
            Expanded(
              child: Center(
                child: IconButton(
                  onPressed: () => { widget.redirect() },
                  icon: const Icon(Icons.fmd_good_rounded ),
                  tooltip: 'Go to location',
                )
              ),
            ),
            Expanded(
              child: Center(
                child: IconButton(
                  onPressed: () => widget.status(),
                  color: Colors.red,
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete',
                )
              )
            )
          ],
        );  
    }
  }
}
