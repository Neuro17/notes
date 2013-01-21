// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library main;

import 'dart:html';
import 'model.dart';
import 'dart:isolate';
import 'package:web_ui/web_ui.dart';
 
main() {
  // listen on changes to #hash in the URL
  // Note: listen on both popState and hashChange, because IE9 doens't support
  // history API, and it doesn't work properly on Opera 12.
  // See http://dartbug.com/5483
//  updateFilters(e) {
//    viewModel.showIncomplete = window.location.hash != '#/completed';
////    viewModel.showDone = window.location.hash != '#/active';
//    dispatch();
//  }
//  new Timer(1, (Timer t) => updateFilters);
  window.on.hashChange.add(updateFilters);
  window.on.popState.add(updateFilters);
  
  var createNewLink = query('#createNewLink');
  createNewLink.on.click.add((event) {
    ModalDialog dialog = new ModalDialog();
    dialog.show();
    new Timer(1, (Timer t) => dialog.transition());
//    dialog.transition();
  });
  
  var refresh = query('#refresh');
  refresh.on.click.add(updateFilters);
  
  document.body.on.change.add(updateFilters);
  
}



void updateFilters(e) {
  viewModel.showIncomplete = window.location.hash != '#/completed';
//    viewModel.showDone = window.location.hash != '#/active';
  dispatch();
}

class ModalDialog {
  
  final DivElement _content;
  final ButtonElement _prova, _addLink;
  final DivElement _blackOverlay;
  final InputElement _link, _title;
//  final InputElement _title;
  
  ModalDialog([String message]) :
    //constructor pre-init
    _content = new Element.tag('div'),
    _blackOverlay = new Element.tag('div'),
    _prova = new Element.tag('button'),
    _addLink = new Element.tag('button'),
    _link = new Element.tag('input'),
    _title = new Element.tag('input')
  
  {
//    _content.id = 'modalContent';
    _content.classes.add('white_content');
//    _blackOverlay.id = 'modalOverlay';
    _blackOverlay.classes.add('black_overlay');
    
    _prova.text = 'x';
    _prova.id = 'esc';
    _prova.style.float = 'right';
    
    _link.placeholder = 'Link';
    _link.id = 'newLink';
    
    _title.placeholder = 'title';
    _title.id = 'newTitle';
    
    _addLink.text = '+ Add Link';
    _addLink.on.click.add(addTodo);
    _addLink.on.click.add((event) {
      hide();
    });
    
    _prova.on.click.add((event) {
      hide();
      updateFilters;
      
    });

    _content.nodes.add(_prova);
    _content.nodes.add(_link);
    _content.nodes.add(_title);
    _content.nodes.add(_addLink);
    
  }

  hide() {
    
    _content.remove();
    _blackOverlay.remove();
    
//    removeFromList(_content, document.body.nodes);
//    removeFromList(_blackOverlay, document.body.nodes);
  }


  show() {
    document.body.nodes.add(_content);
    document.body.nodes.add(_blackOverlay);
  }  
  
  void transition() {
    _content.style.transition = '1s';
    _content.style.transform = getMoveMeTransform();
    
//        _content.classes.add('white_contentTransition');
       
//    _content.style.transitionDuration = '10s';
//    _content.style.transitionProperty = 'width:100px';
//    var position = _content.clientWidth;
    
    
  }
  
  String getMoveMeTransform() {
      return 'translate(120%,0%)';
        
    
  }
}

//removeFromList(var item, var list) {
//  int indexToRemove = 0;
//  for (int i = 0; i < list.length; i++) {
//    var element = list[i];
//    if (element == item) {
//      indexToRemove = i;
//      break;
//    }
//  }
//  list.removeRange(indexToRemove,1);
//}

void addTodo(Event e) {
  e.preventDefault(); // don't submit the form
//  var input = query('#new-todo');
//  var titolo = query('#new-titolo');
  var input = query('#newLink');
  var titolo = query('#newTitle');
  if ((input.value == '')||(titolo.value == '')) return;
  app.links.add(new Link(input.value, titolo.value));
  input.value = '';
  titolo.value = '';
  
//  window.on.hashChange.add(updateFilters);
//  window.on.popState.add(updateFilters);
}
