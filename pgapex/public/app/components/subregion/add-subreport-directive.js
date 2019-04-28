'use strict';
(function (window) {
  let module = window.angular.module('pgApexApp.page');

  function AddSubReportDirective() {
    return {
      scope: {
        viewsWithColumns: '=',
        subReport: '=',
        formError: '=',
        mode: '=',
        index: '='
      },
      controller: 'pgApexApp.region.AddSubReportController',
      templateUrl: 'app/partials/subregion/add-subreport.html',
      restrict: 'E'
    };
  }

  function init() {
    module.directive('addSubReport', AddSubReportDirective);
  }

  init();
})(window);