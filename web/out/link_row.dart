// Auto-generated from link_row.html.
// DO NOT EDIT.

library x_link_row;

import 'dart:html' as autogenerated;
import 'dart:svg' as autogenerated_svg;
import 'package:web_ui/web_ui.dart' as autogenerated;

import 'package:web_ui/web_ui.dart';

import '../model.dart';

import 'editable_lable.dart';

class LinkRow extends WebComponent {
  
  /** Autogenerated from the template. */
  
  /**
  * Shadow root for this component. We use 'var' to allow simulating shadow DOM
  * on browsers that don't support this feature.
  */
  var _root;
  autogenerated.Element __e15, __e8;
  autogenerated.Template __t;
  
  LinkRow.forElement(e) : super.forElement(e);
  
  void created_autogenerated() {
    _root = createShadowRoot();
    __t = new autogenerated.Template(_root);
    if (_root is autogenerated.ShadowRoot) _root.applyAuthorStyles = true;
    
    _root.innerHtml = '''
    <!--<div class="todo-item {{_editingClass}} {{_completedClass}}">-->
    <div class="todo-item">
    <!--<input class="toggle" type="checkbox" bind-checked="todo.done">-->
    <template id="__e-8" style="display:none"></template>
    <template id="__e-15" style="display:none"></template>
    </div>
    ''';
    __e8 = _root.query('#__e-8');
    __t.conditional(__e8, () => (link.letto), (__t) {
      var __e3, __e4, __e5, __e7, __label1;
      __label1 = new autogenerated.Element.html('<x-editable-label id="label1"></x-editable-label>');
      __t.oneWayBind(() => (link.titolo), (e) { __label1.xtag.titolo = e; }, false);
      __t.oneWayBind(() => __label1.xtag.titolo, (__e) { link.titolo = __e; });
      __t.oneWayBind(() => (link.link), (e) { __label1.xtag.value = e; }, false);
      __t.oneWayBind(() => __label1.xtag.value, (__e) { link.link = __e; });
      new EditableLabel.forElement(__label1);
      __t.component(__label1);
      __e3 = new autogenerated.Element.html('<button class="destroy">remove</button>');
      __t.listen(__e3.onClick, ($event) { app.removeTodo(link); });
      __e4 = new autogenerated.Element.html('<button class="unread">unread</button>');
      __t.listen(__e4.onClick, ($event) { app.setRead(link); });
      __e5 = new autogenerated.Element.html('<button class="unread">edit</button>');
      __t.listen(__e5.onClick, ($event) { app.setRead(link); });
      __e7 = new autogenerated.LabelElement();
      var __binding6 = __t.contentBind(() => (link.creationTime));
      __e7.nodes.addAll([
        new autogenerated.Text(' '),
        __binding6,
        new autogenerated.Text(' ')
      ]);
      __t.addAll([
        new autogenerated.Text('\n        '),
        __label1,
        new autogenerated.Text('\n        '),
        __e3,
        new autogenerated.Text('\n        '),
        __e4,
        new autogenerated.Text('\n        '),
        __e5,
        new autogenerated.Text('\n        '),
        __e7,
        new autogenerated.Text('\n        '),
        new autogenerated.Text('\n     ')
      ]);
    });
    
    __e15 = _root.query('#__e-15');
    __t.conditional(__e15, () => (!(link.letto)), (__t) {
      var __e10, __e11, __e12, __e14, __e9, __label2;
      __e9 = new autogenerated.Element.html('<strong><x-editable-label id="label2"></x-editable-label></strong>');
      __label2 = __e9.query('#label2');
      __t.oneWayBind(() => (link.titolo), (e) { __label2.xtag.titolo = e; }, false);
      __t.oneWayBind(() => __label2.xtag.titolo, (__e) { link.titolo = __e; });
      __t.oneWayBind(() => (link.link), (e) { __label2.xtag.value = e; }, false);
      __t.oneWayBind(() => __label2.xtag.value, (__e) { link.link = __e; });
      new EditableLabel.forElement(__label2);
      __t.component(__label2);
      __e10 = new autogenerated.Element.html('<button class="destroy">remove</button>');
      __t.listen(__e10.onClick, ($event) { app.removeTodo(link); });
      __e11 = new autogenerated.Element.html('<button class="unread">read</button>');
      __t.listen(__e11.onClick, ($event) { app.setRead(link); });
      __e12 = new autogenerated.Element.html('<button class="unread">edit</button>');
      __t.listen(__e12.onClick, ($event) { app.setEdit(link); });
      __e14 = new autogenerated.LabelElement();
      var __binding13 = __t.contentBind(() => (link.creationTime));
      __e14.nodes.addAll([
        new autogenerated.Text(' '),
        __binding13,
        new autogenerated.Text(' ')
      ]);
      __t.addAll([
        new autogenerated.Text('\n        '),
        __e9,
        new autogenerated.Text('\n        '),
        __e10,
        new autogenerated.Text('\n        '),
        __e11,
        new autogenerated.Text('      \n        '),
        __e12,
        new autogenerated.Text('  \n        '),
        __e14,
        new autogenerated.Text('\n        '),
        new autogenerated.Text('\n     ')
      ]);
    });
    
    __t.create();
  }
  
  void inserted_autogenerated() {
    __t.insert();
  }
  
  void removed_autogenerated() {
    __t.remove();
    __e15 = __e8 = __t = null;
  }
  
  void composeChildren() {
    super.composeChildren();
    if (_root is! autogenerated.ShadowRoot) _root = this;
  }
  
  /** Original code from the component. */
  
  Link link;
  //bool get editing => _root.query('#label').xtag.editing;
  //String get _completedClass => link.done ? 'completed' : '';
  //String get _editingClass => editing ? 'editing' : '';
}

