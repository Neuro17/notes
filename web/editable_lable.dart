import 'dart:html';
import 'package:web_ui/web_ui.dart';

  /**
   * Label whose [value] can be edited by double clicking. When editing, it
   * displays a form and input element, otherwise it displays the label. You
   * can enable two-way binding like this:
   *
   *     <x-editable-label bind-value="{{dartAsignableValue}}">
   *     </x-editable-label>
   */
  class EditableLabel extends WebComponent {
    bool editing;
    String value;
    String titolo; // da usare

    InputElement get _editBox => document.query('#edit');


    void created() {
      super.created();
      editing = false;
      value = '';

    }

    void edit() {
      editing = true;
      dispatch();

      // For IE and Firefox: use .focus(), then reset the value to move the
      // cursor to the end.
      _editBox.focus();
      _editBox.value = '';
      _editBox.value = value;
    }

    void update(Event e) {
      e.preventDefault(); // don't submit the form
      if (!editing) return; // bail if user canceled
      value = _editBox.value;

      editing = false;
    }

    void maybeCancel(KeyboardEvent e) {
      if (e.keyCode == KeyCode.ESC) {
        editing = false;
      }
    }
  }
