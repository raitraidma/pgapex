'use strict';
function checkAll(headerCheckbox) {
  let checkboxes = $(headerCheckbox).closest('form').find(':checkbox');
  checkboxes.prop('checked', $(headerCheckbox).is(':checked'));
}