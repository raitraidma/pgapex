'use strict';
(function (window) {
  var module = window.angular.module('pgApexApp.page');

  function AddButtonDirective() {
    return {
      scope: {
        buttons: '=',
        functions: '=',
        buttonTemplates: '=',
        formError: '=',
        lastSequence: '=',
        title: '@',
        attributeTitle: '@'
      },
      controller: 'pgApexApp.region.AddButtonController',
      templateUrl: 'app/partials/region/add-button.html',
      restrict: 'E'
    };
  }

  function init() {
    module.directive('addButton', AddButtonDirective);
  }

  init();
})(window);