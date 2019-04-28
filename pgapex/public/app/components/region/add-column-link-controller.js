'use strict';
(function (window) {
  let module = window.angular.module('pgApexApp.page');
  
  function AddColumnLinkController($scope, formErrorService) {
    this.$scope = $scope;
    this.formErrorService = formErrorService;

    this.init();
  }

  AddColumnLinkController.prototype.init = function () {
    this.$scope.addColumn = this.addColumn.bind(this);
    this.$scope.deleteColumn = this.deleteColumn.bind(this);
  };

  AddColumnLinkController.prototype.addColumn = function (type) {
    this.$scope.columns.push({'attributes': {'type': type, 'isTextEscaped': true}});
  };

  AddColumnLinkController.prototype.deleteColumn = function (columnPosition) {
    this.$scope.columns.splice(columnPosition, 1);
    this.$scope.formError = this.formErrorService.empty();
  };

  function init() {
    module.controller('pgApexApp.region.AddColumnLinkController', ['$scope', 'formErrorService', AddColumnLinkController]);
  }

  init();
})(window);