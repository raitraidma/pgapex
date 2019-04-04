'use strict';
(function (window) {
  let module = window.angular.module('pgApexApp.page');

  function AddButtonDirective() {
    return {
      scope: {
        applicationId: '=',
        formNames: '=',
        buttons: '=',
        buttonTemplates: '='
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