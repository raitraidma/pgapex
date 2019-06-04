'use strict';
(function (window) {
  let module = window.angular.module('pgApexApp.page');
  
  function AddColumnLinkController($scope, formErrorService, helperService) {
    this.$scope = $scope;
    this.formErrorService = formErrorService;
    this.$scope.helper = helperService;

    this.init();
  }

  AddColumnLinkController.prototype.init = function () {
    this.$scope.addColumn = this.addColumn.bind(this);
    this.$scope.deleteColumn = this.deleteColumn.bind(this);
  };

  AddColumnLinkController.prototype.addColumn = function (type) {
    this.$scope.lastSequence++;
    this.$scope.columns.push({'attributes': {'type': type, 'isTextEscaped': true, 'sequence': this.$scope.lastSequence}});
  };

  AddColumnLinkController.prototype.deleteColumn = function (columnPosition) {
    this.$scope.columns.splice(columnPosition, 1);
    this.$scope.formError = this.formErrorService.empty();
  };

  function init() {
    module.controller('pgApexApp.region.AddColumnLinkController', ['$scope', 'formErrorService', 'helperService',
      AddColumnLinkController]);
  }

  init();
})(window);