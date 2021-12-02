import 'dart:typed_data';
import 'dart:io';

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
  final GlobalKey<EpubViewState> _epubViewKey = GlobalKey();

  List<AlexandrioBookmark> bookmarkList = [];
  bool isLongPressed = false;
  double button1pos = 1.5;
  double button2pos = 1.5;

  Future<bool> _initBookmarkList() async {
    var tmp = await _alexandrioController.getAllUserData(widget.token, widget.library, widget.book);
    setState(() {
      for (var data in tmp) {
        bookmarkList.add(AlexandrioBookmark(
            pos: data[0],
            id: bookmarkList.length + 1,
            status: () {},
            redirect: () {
              _epubRedirect(data[0]);
            },
            isNote: data[data.length - 1] == 'note' ? true : false,
            note: data[2],
            dataId: data[1]));
      }
    });
    return true;
  }

  void _showBookmarkOptions() {
    setState(() {
      button1pos = 0.95;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        button2pos = 0.8;
      } else {
        button2pos = 0.5;
      }
      isLongPressed = true;
    });
  }

  void _epubRedirect(String position) {
    _epubViewKey.currentState!.goToPosition(double.parse(position));
    Navigator.pop(context);
  }

  Future<void> _fillIconList(String position, bool _isNote, String _note, int _id) async {
    setState(() {
      var tmp = AlexandrioBookmark(
          pos: position,
          id: _id,
          status: () {},
          redirect: () {
            _epubRedirect(position);
          },
          isNote: _isNote,
          note: _note,
          dataId: '');
      bookmarkList.add(tmp);
    });
    _alexandrioController.postUserData(widget.token, widget.library, widget.book, _isNote ? 'note' : 'bookmark', _note, _isNote ? 'note' : 'bookmark', position);
  }

  Future<void> _removeIconFromList(int _id, String _dataId) async {
    setState(() {
      bookmarkList.removeWhere((element) => element.id == _id);
    });
    _alexandrioController.deleteUserData(widget.token, widget.library, widget.book, _dataId);
  }

  @override
  void initState() {
    _alexandrioController = AlexandrioAPIController();
    _epubController = EpubController(document: EpubReader.readBook(widget.bytes));
    _scrollController = ScrollController();
    _textEditingController = TextEditingController();

    _initBookmarkList();

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
            onPressed: () {
              _globalKey.currentState!.openEndDrawer();
            },
            icon: const Icon(Icons.bookmark),
            tooltip: "Bookmarks",
          ),
          IconButton(
            onPressed: () {
              var progression = _epubViewKey.currentState!.position();
              _alexandrioController.postProgression(widget.token, widget.book, widget.library, progression);
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
      )),
      endDrawer: Drawer(
          child: ListView(children: [
        for (var bookmark in bookmarkList)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Material(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(32.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          !bookmark.isNote ? Icons.bookmark : Icons.book,
                          color: Colors.white.withAlpha(196),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // if (bookmark.isNote)
                        Text(
                          bookmark.isNote ? 'Note' : 'Bookmark',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          bookmark.isNote ? '${bookmark.note}' : '',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _epubViewKey.currentState!.goToPosition(double.parse(bookmark.pos!));
                    },
                    icon: const Icon(Icons.fmd_good_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      _removeIconFromList(bookmark.id, bookmark.dataId);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ),
      ])),
      endDrawerEnableOpenDragGesture: true,
      body: Stack(
        children: [
          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPressStart: (LongPressStartDetails details) => {
                    _showBookmarkOptions(),
                  },
              onTap: () => {
                    setState(() => {isLongPressed = false})
                  },
              child: Center(
                  child: AspectRatio(
                aspectRatio: 1 / 1.4142,
                child: EpubView(key: _epubViewKey, controller: _epubController, progression: widget.progress!),
              ))),
          if (isLongPressed == true)
            Align(
                alignment: Alignment(button1pos, 0.9),
                child: FloatingActionButton(
                  tooltip: "Add a bookmark",
                  child: const Icon(Icons.bookmark),
                  onPressed: () => {_fillIconList(_epubViewKey.currentState!.position(), false, '', bookmarkList.length + 1), button1pos = 1.5, button2pos = 1.5},
                )),
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
                                    onPressed: () => {_fillIconList(_epubViewKey.currentState!.position(), true, _textEditingController.text, bookmarkList.length + 1), button1pos = 1.5, button2pos = 1.5, _textEditingController.text = '', Navigator.pop(context, "Add")},
                                    child: const Text("Add"),
                                  ),
                                  TextButton(onPressed: () => {button1pos = 1.5, button2pos = 1.5, Navigator.pop(context, "Cancel")}, child: const Text("Cancel"))
                                ])))),
        ],
      ),
    );
  }
}
