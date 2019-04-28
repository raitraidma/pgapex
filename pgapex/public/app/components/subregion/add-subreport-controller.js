'use strict';
(function (window) {
  let module = window.angular.module('pgApexApp.page');

  function AddSubReportController($scope, databaseService, formErrorService) {
    this.$scope = $scope;
    this.databaseService = databaseService;
    this.formErrorService = formErrorService;

    $scope.$watch('subReport.columns', function (items) {
      $scope.subReportForm.$setValidity('columnsArrayLength', items.length > 0);
    }, true);

    this.init();
  }

  AddSubReportController.prototype.init = function () {
    this.$scope.changeViewColumns = this.changeViewColumns.bind(this);
    this.$scope.subReport.index = this.$scope.index;

    this.$scope.trackView = function(view) {
      if (!view || !view.attributes) { return view; }
      return view.attributes.schema + '.' + view.attributes.name;
    }.bind(this);

    this.loadSubReport();
  };

  AddSubReportController.prototype.setViewColumns = function() {
    if (!this.$scope.subReport.view) { return; }
    const view = this.$scope.viewsWithColumns.filter(function (view) {
      return view.attributes.schema === this.$scope.subReport.view.attributes.schema &&
        view.attributes.name === this.$scope.subReport.view.attributes.name;
    }.bind(this));
    if (view.length > 0) {
      this.$scope.viewColumns = view[0].attributes.columns;
    }
  };

  AddSubReportController.prototype.changeViewColumns = function() {
    this.setViewColumns();
  };

  AddSubReportController.prototype.loadSubReport = function() {
    if (this.$scope.mode === 'edit') {
      this.$scope.subReport.view = {'attributes':
        {
          'schema': this.$scope.subReport.viewSchema,
          'name': this.$scope.subReport.viewName
        }
      };
      this.setViewColumns();
    }
  };

  function init() {
    module.controller('pgApexApp.region.AddSubReportController', ['$scope', 'databaseService', 'formErrorService', AddSubReportController]);
  }

  init();
})(window);