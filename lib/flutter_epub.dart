import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart' as flutter hide Element;
import 'package:html/dom.dart' as dom;
import 'package:epubx/epubx.dart';
import 'package:html/parser.dart' as html;

import 'package:alexandrio_epub/epub.dart';

class AlexandrioEpub {

  void getBookInfos(EpubBook epubBook) async {
    BookContent book = BookContent();
    book.title = epubBook.Title!;
    var content = epubBook.Content;

    print(book.title);

    var chapters = getAllChapters(epubBook);

    return;
  }

  List<EpubChapter> getAllChapters(EpubBook epubBook) =>
    epubBook.Chapters!.fold<List<EpubChapter>>(
      [],
      (current, next) {
        current.add(next);
        next.SubChapters!.forEach(current.add);
        return current;
      },
    );

  List<dom.Element> removeDivs(List<dom.Element> content) {
    final result = <dom.Element>[];

    for (final node in content) {
      if (node.localName == 'div' && node.children.length > 1) {
        result.addAll(removeDivs(node.children));
      } else {
        result.add(node);
      }
    }

    return result;
  }

  Future<BookInfos> fillTextList(flutter.BuildContext context, EpubBook epubBook) async {
    var bookInfos = BookInfos(widgets: []);

    epubBook.Chapters!.forEach((EpubChapter chapter) async {
      dom.Document content = html.parse(chapter.HtmlContent);

      bookInfos.htmlContent.add(content.body!);
      // if (infos != null && infos.htmlContent.isNotEmpty) {
      //   for (var i = 0; i < infos.htmlContent.length; ++i) {
      //     // bookInfos.widgets.add(infos.widgets[i]);
      //     bookInfos.htmlContent.add(infos.htmlContent[i]);
      //   }
      // }

      chapter.SubChapters!.forEach((EpubChapter subchapter) async {
        dom.Document content = html.parse(subchapter.HtmlContent);
        
        bookInfos.htmlContent.add(content.body!);
        // if (infos != null && infos.htmlContent.isNotEmpty) {
        //   for (var i = 0; i < infos.htmlContent.length; ++i) {
        //     // bookInfos.widgets.add(infos.widgets[i]);
        //     bookInfos.htmlContent.add(infos.htmlContent[i]);
        //   }
        // }

        if (subchapter.SubChapters!.isNotEmpty) {
          subchapter.SubChapters!.forEach((EpubChapter subsubchapter) async {
            dom.Document content = html.parse(subsubchapter.HtmlContent);

            bookInfos.htmlContent.add(content.body!);
            // if (infos != null && infos.htmlContent.isNotEmpty) {
            //   for (var i = 0; i < infos.htmlContent.length; ++i) {
            //     // bookInfos.widgets.add(infos.widgets[i]);
            //     bookInfos.htmlContent.add(infos.htmlContent[i]);
            //   }
            // }
          });
        }
      });
    });

    return bookInfos;
  }

  AlexandrioEpub();

}
