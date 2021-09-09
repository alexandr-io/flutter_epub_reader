import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

class BookData {
  List<Widget> widgets = [];
  List<dom.Element> content = [];

  BookData({ required this.widgets, required this.content});
}