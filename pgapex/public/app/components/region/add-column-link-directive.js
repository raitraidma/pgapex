'use strict';
(function (window) {
  var module = window.angular.module('pgApexApp.page');

  function AddColumnLinkDirective() {
    return {
      scope: {
        columns: '=',
        viewColumns: '=',
        formError: '=',
        lastSequence: '=',
        name: '@',
        title: '@',
        attributeTitle: '@'
      },
      controller: 'pgApexApp.region.AddColumnLinkController',
      templateUrl: 'app/partials/region/add-column-link.html',
      restrict: 'E'
    };
  }

  function init() {
    module.directive('addColumnLink', AddColumnLinkDirective);
  }

  init();
})(window);