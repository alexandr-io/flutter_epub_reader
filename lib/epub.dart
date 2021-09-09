import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

class BookInfos {
  List<Widget> widgets = [];
  List<dom.Element> htmlContent = [];

  BookInfos({
    required this.widgets,
  });
}

class PageContent {
  SelectableText widgetTitle = const SelectableText('');
  SelectableText widgetSubtitle = const SelectableText('');
  String subtitle = '';
  List<Widget> widgets = [];
  // void highlightText();
  // void addNote();

  PageContent({
    required this.widgets,
    required this.subtitle,
  });
}

class BookContent {
  int pages = 0;
  int currentPage = 0;
  String title = '';
  
  List<PageContent> content = [];

  BookContent();
}