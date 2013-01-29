library AddLink;

import 'package:web_ui/web_ui.dart';
import 'model.dart';
import 'dart:html';
  
class AddLink extends WebComponent {
  Link link;
  
  void addTodo(Event e) {
    e.preventDefault(); // don't submit the form
    var input = query('#new-todo');
    var titolo = query('#new-titolo');
    if ((input.value == '')||(titolo.value == '')) return;
    app.links.add(new Link(input.value, titolo.value));
    input.value = '';
    titolo.value = '';
  } 
  //bool get editing => _root.query('#label').xtag.editing;
  //String get _completedClass => link.done ? 'completed' : '';
  //String get _editingClass => editing ? 'editing' : '';
}