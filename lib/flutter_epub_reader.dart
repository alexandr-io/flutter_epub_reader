import 'dart:typed_data';

import 'package:epub_view/epub_view.dart';
import 'package:epubx/epubx.dart' hide Image;
import 'package:flutter/material.dart';

import 'flutter_bookmark.dart';
import 'flutter_epub.dart';

class EPUBBook extends StatefulWidget {
  final String book;
  final String library;
  final String token;
  final Uint8List bytes;
  final String title;
  final String? progress;

  const EPUBBook({
    Key? key,
    required this.book,
    required this.library,
    required this.token,
    required this.bytes,
    required this.title,
    required this.progress,
  }) : super(key: key);

  @override
  _EPUBBookState createState() => _EPUBBookState();
}

class _EPUBBookState extends State<EPUBBook> {
  late AlexandrioAPIController _alexandrioController;
  late EpubController _epubController;
  late ScrollController _scrollController;
  late TextEditingController _textEditingController;

  List<AlexandrioBookmark> bookmarkList = [];
  bool isLongPressed = false;
  double button1pos = 1.5;
  double button2pos = 1.5;
  double currentPosX = 0;
  double currentPosY = 0;

  void _showIconOption(LongPressStartDetails details, BuildContext context) {
    setState(() {
      isLongPressed = true;
      currentPosX = MediaQuery.of(context).size.width - 100;
      currentPosY = details.globalPosition.dy;
    });
  }

  void _fillIconList(double _posX, double _posY, bool _isNote, String _note, int _id) {
    setState(() {
      var tmp = AlexandrioBookmark(
          posX: _posX,
          posY: _posY,
          id: _id,
          status: () {
            _removeIconFromList(_id);
          },
          isNote: _isNote,
          note: _note);
      bookmarkList.add(tmp);
    });
  }

  void _removeIconFromList(int _id) {
    setState(() {
      bookmarkList.removeWhere((element) => element.id == _id);
    });
  }

  @override
  void initState() {
    _alexandrioController = AlexandrioAPIController();
    _epubController = EpubController(document: EpubReader.readBook(widget.bytes), epubCfi: widget.progress);
    _scrollController = ScrollController();
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _epubController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              final cfi = _epubController.generateEpubCfi();
              _alexandrioController.postProgression(widget.token, widget.book, widget.library, cfi);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
          )
        ],
      ),
      drawer: Drawer(
          child: EpubReaderTableOfContents(
        controller: _epubController,
      )),
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onLongPressStart: (LongPressStartDetails details) => {button1pos = 0.95, button2pos = 0.8, _showIconOption(details, context)},
            onTap: () => {
              setState(() => {isLongPressed = false})
            },
            child: Center(
              child: AspectRatio(
                aspectRatio: 1 / 1.4142,
                child: EpubView(controller: _epubController),
              ),
            ),
          ),
          if (isLongPressed == true) Align(alignment: Alignment(button1pos, 0.9), child: FloatingActionButton(tooltip: "Add a bookmark", child: const Icon(Icons.star), onPressed: () => {_fillIconList(currentPosX, currentPosY, false, '', bookmarkList.length + 1), button1pos = 1.5, button2pos = 1.5})),
          if (isLongPressed == true)
            Align(
              alignment: Alignment(button2pos, 0.9),
              child: FloatingActionButton(
                tooltip: "Add a note",
                child: const Icon(Icons.notes),
                onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Write your note'),
                    content: TextField(
                      controller: _textEditingController,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => {_fillIconList(currentPosX, currentPosY, true, _textEditingController.text, bookmarkList.length + 1), button1pos = 1.5, button2pos = 1.5, Navigator.pop(context, "Add")},
                        child: const Text("Add"),
                      ),
                      TextButton(onPressed: () => {button1pos = 1.5, button2pos = 1.5, Navigator.pop(context, "Cancel")}, child: const Text("Cancel"))
                    ],
                  ),
                ),
              ),
            ),
          ...bookmarkList,
        ],
      ),
    );
  }
}
