'use strict';
(function (window) {
  var module = window.angular.module('pgApexApp.page');

  function AddButtonController($scope, formErrorService, helperService) {
    this.$scope = $scope;
    this.formErrorService = formErrorService;
    this.$scope.helper = helperService;

    this.init();
  }

  AddButtonController.prototype.init = function () {
    this.$scope.addButton = this.addButton.bind(this);
    this.$scope.deleteButton = this.deleteButton.bind(this);

    this.$scope.trackFunction = function(functionWithParameters) {
      if (!functionWithParameters || !functionWithParameters.attributes) { return functionWithParameters; }
      return functionWithParameters.attributes.schema + '.' + functionWithParameters.attributes.name;
    };
  };

  AddButtonController.prototype.addButton = function () {
    this.$scope.lastSequence++;
    this.$scope.buttons.push({'appUserParameter': false, 'sequence': this.$scope.lastSequence});
  };

  AddButtonController.prototype.deleteButton = function (buttonPosition) {
    this.$scope.buttons.splice(buttonPosition, 1);
    this.$scope.formError = this.formErrorService.empty();
  };

  function init() {
    module.controller('pgApexApp.region.AddButtonController', ['$scope', 'formErrorService', 'helperService',
      AddButtonController]);
  }

  init();
})(window);