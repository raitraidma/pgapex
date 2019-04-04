'use strict';
(function (window) {
  let module = window.angular.module('pgApexApp.page');

  function AddColumnLinkDirective() {
    return {
      scope: {
        names: '<',
        columns: '<',
        viewColumns: '<'
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