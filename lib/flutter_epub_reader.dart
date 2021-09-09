import 'dart:typed_data';
import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:epubx/epubx.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '/data/book_data.dart';

class EPUBBook extends StatefulWidget {
  final String id;
  final String token;
  final Uint8List bytes;

  const EPUBBook({
    required Key key,
    required this.id,
    required this.token,
    required this.bytes
  }) : super(key: key);

  @override
  _EPUBBookState createState() => _EPUBBookState();
}

class _EPUBBookState extends State<EPUBBook> {
  late EpubController _epubController;
  late ScrollController _scrollController;
  late EpubBook _book;

  bool compatibility = true;

  @override
  void initState() {
    _epubController = EpubController(
      document: EpubReader.readBook(widget.bytes)
    );
    _scrollController = ScrollController();
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
        title: const Text('Test'),
        actions: [
          IconButton(
            onPressed: () async => setState(() {
              compatibility = !compatibility;
            }),
            icon: const Icon(Icons.compare),
          )
        ],
      ),
      body: compatibility
        ? EpubView(controller: _epubController)
        : Center(
          child: AspectRatio(
            aspectRatio: (Platform.isWindows || Platform.isLinux || Platform.isMacOS) ? 4 / 3 : 1 / 2,
            child: NotificationListener<ScrollNotification> (
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification) {
                  var progress = (_scrollController.offset * 100) / _scrollController.position.maxScrollExtent;
                  // AlexandrioAPI().updateBookProgress(widget.credentials, widget.library, widget.book, progress.toString());
                }
                return true;
              },
              child: ListView(
                controller: _scrollController,
                // children: [
                //   SizedBox(height: 64.0),
                //   FutureBuilder<>(
                //     future: ,
                //     builder: (BuildContext context, AsyncSnapshot<> snapshot) {
                //       if (snapshot.hasData) {
                //         var content = snapshot.data;
                //         return Center(
                //           child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                //             for (var html in content.htmlContent)
                //               Html(
                //                 data: html.outerHtml,
                //                 customRender: {
                //                   'img': (context, child, attributes, node) {
                //                     final url = attributes['src'].replaceAll('../', '');
                //                     return Image(
                //                       image: MemoryImage(
                //                         Uint8List.fromList(_book.Content.Images[url].Content),
                //                       )
                //                     );
                //                   }
                //                 },
                //               ),
                //           ]),
                //         );
                //       }
                //     }
                //   )
                // ],
              )
            ),
          )
        ),
    );
  }

  // Future<BookData> _getEpubData(BuildContext context) async {
  //   var epub = await EpubReader.readBook(widget.bytes);
  //   _book = epub;

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     var offset = (double.parse(widget.progression ?? '0') * _scrollController.position.maxScrollExtent) / 100;
  //     _scrollController.jumpTo(offset);
  //   });

  //   return fillTextList(context, epub);
  // }
}