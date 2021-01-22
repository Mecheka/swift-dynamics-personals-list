import 'package:flutter/widgets.dart';

abstract class CreateTodoListType {}

class AddItem extends CreateTodoListType {}

class ContentItem extends CreateTodoListType {
  // ignore: unused_field
  TextEditingController controller;

  ContentItem({String text = ""}) {
    controller = TextEditingController(text: text);
  }
}
