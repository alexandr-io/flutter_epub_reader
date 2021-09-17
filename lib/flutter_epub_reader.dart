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
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  List<AlexandrioBookmark> bookmarkList = [];
  bool isLongPressed = false;
  double button1pos = 1.5;
  double button2pos = 1.5;

  Future<bool> _initBookmarkList() async {
    var tmp = await _alexandrioController.getAllUserData(widget.token, widget.library, widget.book);
    setState(() {
      for (var data in tmp) {
        bookmarkList.add(AlexandrioBookmark(pos: data[0], id: bookmarkList.length + 1, status: () { _removeIconFromList(bookmarkList.length + 1); }, redirect: () { _epubRedirect(data[0]); }, isNote: data[data.length - 1] == 'note' ? true : false, note: data[2], dataId: data[1]));
      }
    });
    return true;
  }

  void _showBookmarkOptions() {
    setState(() {
      button1pos = 0.95;
      button2pos = 0.8;
      isLongPressed = true;
    });
  }

  void _epubRedirect(String cfi) {
    _epubController.gotoEpubCfi(cfi);
    Navigator.pop(context);
  }
  
  void _fillIconList(String cfi, bool _isNote, String _note, int _id) {
    setState(() {
      var tmp = AlexandrioBookmark(pos: cfi, id: _id, status: () { _removeIconFromList(_id); }, redirect: () { _epubRedirect(cfi); }, isNote: _isNote, note: _note, dataId: '');
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
    _initBookmarkList().then((tmp) {
      if (bookmarkList.isNotEmpty) _alexandrioController.deleteAllUserData(widget.token, widget.library, widget.book);
    });
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
      key: _globalKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () { _globalKey.currentState!.openEndDrawer(); },
            icon: const Icon(Icons.bookmark),
            tooltip: "Bookmarks",
          ),
          IconButton(
            onPressed: () {
              final cfi = _epubController.generateEpubCfi();
              _alexandrioController.postProgression(widget.token, widget.book, widget.library, cfi);
              bookmarkList.forEach((element) {
                _alexandrioController.postUserData(widget.token, widget.library, widget.book, element.isNote ? 'note' : 'bookmark', element.note, element.isNote ? 'note' : 'bookmark', element.pos!);
              });
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            tooltip: "Return",
          )
        ],
      ),
      drawer: Drawer(
        child: EpubReaderTableOfContents(
          controller: _epubController,
        )
      ),
      endDrawer: Drawer(
        child: 
        // FutureBuilder<List<List<String>>> (
        //   future: _alexandrioController.getAllUserData(widget.token, widget.library, widget.book),
        //   builder: (context, snapshot) {
        //     if (snapshot.hasData) {
        //       for (var data in snapshot.data!) {
        //         bookmarkList.add(AlexandrioBookmark(pos: data[0], id: bookmarkList.length + 1, status: () { _removeIconFromList(bookmarkList.length + 1); }, redirect: () { _epubRedirect(data[0]); }, isNote: data[data.length] == 'note' ? true : false, note: data[2], dataId: data[1]));
        //       } 
        //       if (bookmarkList.isNotEmpty) _alexandrioController.deleteAllUserData(widget.token, widget.library, widget.book);
        //       return 
              ListView(
                children: [
                  ...bookmarkList
                ],
              )
        //     }
        //     return const CircularProgressIndicator.adaptive();
        //   }
        // )
      ),
      endDrawerEnableOpenDragGesture: true,
      body:
          Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPressStart: (LongPressStartDetails details) => {
                  _showBookmarkOptions(),
                },
                onTap: () => { setState(() => { isLongPressed = false }) },
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1 / 1.4142,
                    child: EpubView(controller: _epubController),
                  )
                )
              ),
              if (isLongPressed == true)
                Align(
                  alignment: Alignment(button1pos, 0.9),
                  child: FloatingActionButton(
                    tooltip: "Add a bookmark",
                    child: const Icon(Icons.star),
                    onPressed: () => {
                      _fillIconList(_epubController.generateEpubCfi()!, false, '', bookmarkList.length + 1),
                      button1pos = 1.5,
                      button2pos = 1.5
                    }
                  )
                ),
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
                            onPressed: () => {
                              _fillIconList(_epubController.generateEpubCfi()!, true, _textEditingController.text, bookmarkList.length + 1),
                              button1pos = 1.5,
                              button2pos = 1.5,
                              Navigator.pop(context, "Add")
                            },
                            child: const Text("Add"),
                          ),
                          TextButton(
                            onPressed: () => {
                              button1pos = 1.5,
                              button2pos = 1.5,
                              Navigator.pop(context, "Cancel")
                            },
                            child: const Text("Cancel")
                          )
                        ]
                      )
                    )
                  )
                ),
            ], 
          ),
    );
  }
}
