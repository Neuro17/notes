// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library model;

class ViewModel {
  bool isVisible(Link link) => link != null;
//  &&
//      ((showIncomplete && !link.done) || (showDone && link.done));

  bool showIncomplete = true;

  bool showDone = true;
  
//  bool isRead(Link link) => link.letto;
}

final ViewModel viewModel = new ViewModel();

// The real model:

class AppModel {
  List<Link> links = <Link>[];

  // TODO(jmesserly): remove this once List has a remove method.
  void removeTodo(Link link) {
    var index = links.indexOf(link);
    if (index != -1) {
      links.removeRange(index, 1);
    }
  }
  
  void setRead(Link link) {
    var index = links.indexOf(link);
    if (index != -1) {
        if(links[index].letto) {
          links[index].letto = false;
        }
        else links[index].letto = true;
    }
  }
  
  void setEdit(Link link) {
    var index = links.indexOf(link);
    if (index != -1) {
        if(!links[index].editing) {
          links[index].editing = true;
        }
        else links[index].letto = false;
    }
  }
   

//  bool get allChecked => todos.length > 0 && todos.every((t) => t.done);
//
//  set allChecked(bool value) => todos.forEach((t) { t.done = value; });

//  int get doneCount {
//    int res = 0;
//    todos.forEach((t) { if (t.done) res++; });
//    return res;
//  }
//
//  int get remaining => todos.length - doneCount;
//
//  void clearDone() {
//    todos = todos.filter((t) => !t.done);
//  }
}

final AppModel app = new AppModel();

class Link {
  String link;
//  bool done = false;
  String titolo;
  bool letto = true;
  bool editing = false;
  
  
  int creationDay = new Date.now().day;
  int creationMonth = new Date.now().month;
  int crationYear = new Date.now().year;
  
  Date creationTime = new Date.now();

  Link(this.link, this.titolo);
  
//  String toString() => "$task ${done ? '(done)' : '(not done)'}";
}
