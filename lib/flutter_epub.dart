import 'dart:convert';

import 'package:flutter_epub_reader/flutter_bookmark.dart';
import 'package:http/http.dart' as http;

class AlexandrioAPIController {

  Future<void> postProgression(String token, String book, String library, String? progress) async {
    var response = await http.post(
      Uri.parse('https://library.alexandrio.cloud/library/$library/book/$book/progress'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"progress": progress})
    );

    if (response.statusCode != 200) throw 'Coudn\'t update progress';
  }

  Future<List<List<String>>> getAllUserData(String token, String libraryId, String bookId) async {
    var response = await http.get(
      Uri.parse('https://library.alexandrio.cloud/library/$libraryId/book/$bookId/data'),
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }
    );

    List<List<String>> bookmarkList = [];

    if (response.statusCode != 200) throw 'Couldn\'t get user data';

    if (response.body != "null") {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      for (var data in json) {
        List<String> tmp = [];

        tmp.add(data['offset']);
        tmp.add(data['id']);
        if (data['type'] == 'note') tmp.add(data['name']);
        tmp.add(data['type']);
        bookmarkList.add(tmp);
      }
    }
    // List<AlexandrioBookmark> array = [];
    
    return bookmarkList;
  }

  Future<void> deleteAllUserData(String token, String libraryId, String bookId) async {
    var response = await http.delete(
      Uri.parse('https://library.alexandrio.cloud/library/$libraryId/book/$bookId/data'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode != 200) throw 'Couldn\'t delete all data';
  }

  Future<void> postUserData(String token, String libraryId, String bookId, String type, String description, String name, String offset) async {
    var response = await http.post(
      Uri.parse('https://library.alexandrio.cloud/library/$libraryId/book/$bookId/data'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        "name": description.isEmpty ? type : description,
        "offset": offset,
        "description": description,
        "type": type
      })
    );

    if (response.statusCode != 201) throw 'Couldn\'t create data';
  }

  void deleteUserData(String token, String libraryId, String bookId, String dataId) async {
    var response = await http.delete(
      Uri.parse('https://library.alexandrio.cloud/library/$libraryId/book/$bookId/data/$dataId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }
    );

    if (response.statusCode != 200) throw 'Couldn\'t delete data';
  }

  // List<EpubChapter> getAllChapters(EpubBook epubBook) => epubBook.Chapters!.fold<List<EpubChapter>>(
  //       [],
  //       (current, next) {
  //         current.add(next);
  //         next.SubChapters!.forEach(current.add);
  //         return current;
  //       },
  //     );

  // List<dom.Element> removeDivs(List<dom.Element> content) {
  //   final result = <dom.Element>[];

  //   for (final node in content) {
  //     if (node.localName == 'div' && node.children.length > 1) {
  //       result.addAll(removeDivs(node.children));
  //     } else {
  //       result.add(node);
  //     }
  //   }

  //   return result;
  // }

  // Future<BookInfos> fillTextList(flutter.BuildContext context, EpubBook epubBook) async {
  //   var bookInfos = BookInfos(widgets: []);

  //   epubBook.Chapters!.forEach((EpubChapter chapter) async {
  //     dom.Document content = html.parse(chapter.HtmlContent);

  //     bookInfos.htmlContent.add(content.body!);
  //     // if (infos != null && infos.htmlContent.isNotEmpty) {
  //     //   for (var i = 0; i < infos.htmlContent.length; ++i) {
  //     //     // bookInfos.widgets.add(infos.widgets[i]);
  //     //     bookInfos.htmlContent.add(infos.htmlContent[i]);
  //     //   }
  //     // }

  //     chapter.SubChapters!.forEach((EpubChapter subchapter) async {
  //       dom.Document content = html.parse(subchapter.HtmlContent);

  //       bookInfos.htmlContent.add(content.body!);
  //       // if (infos != null && infos.htmlContent.isNotEmpty) {
  //       //   for (var i = 0; i < infos.htmlContent.length; ++i) {
  //       //     // bookInfos.widgets.add(infos.widgets[i]);
  //       //     bookInfos.htmlContent.add(infos.htmlContent[i]);
  //       //   }
  //       // }

  //       if (subchapter.SubChapters!.isNotEmpty) {
  //         subchapter.SubChapters!.forEach((EpubChapter subsubchapter) async {
  //           dom.Document content = html.parse(subsubchapter.HtmlContent);

  //           bookInfos.htmlContent.add(content.body!);
  //           // if (infos != null && infos.htmlContent.isNotEmpty) {
  //           //   for (var i = 0; i < infos.htmlContent.length; ++i) {
  //           //     // bookInfos.widgets.add(infos.widgets[i]);
  //           //     bookInfos.htmlContent.add(infos.htmlContent[i]);
  //           //   }
  //           // }
  //         });
  //       }
  //     });
  //   });

  //   return bookInfos;
  // }

  AlexandrioAPIController();
}
