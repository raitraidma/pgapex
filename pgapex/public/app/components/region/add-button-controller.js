'use strict';
(function (window) {
  let module = window.angular.module('pgApexApp.page');

  function AddButtonController($scope, databaseService, formErrorService) {
    this.$scope = $scope;
    this.databaseService = databaseService;
    this.formErrorService = formErrorService;

    this.init();
  }

  AddButtonController.prototype.init = function () {
    this.$scope.addButton = this.addButton.bind(this);
    this.$scope.deleteButton = this.deleteButton.bind(this);

    this.initFunctions();
  };

  AddButtonController.prototype.addButton = function () {
    this.$scope.buttons.push({'appUserParameter': false});
  };

  AddButtonController.prototype.deleteButton = function (buttonPosition) {
    this.$scope.buttons.splice(buttonPosition, 1);
    this.$scope.formError = this.formErrorService.empty();
  };

  AddButtonController.prototype.initFunctions = function() {
    this.databaseService.getFunctionsWithParameters(this.$scope.applicationId).then(function (response) {
      let functions = response.getDataOrDefault([]);
      functions.forEach(function (functionWithParameter) {
        functionWithParameter.attributes.parameters.sort(function(firstParameter, secondParameter) {
          return firstParameter.attributes.ordinalPosition - secondParameter.attributes.ordinalPosition;
        });
      });
      functions.forEach(function(functionWithParameter) {
        this.addDisplayTextToFunction(functionWithParameter);
      }.bind(this));
      this.$scope.functions = functions;
    }.bind(this));
  };

  AddButtonController.prototype.addDisplayTextToFunction = function(functionWithParameter) {
    let displayText = functionWithParameter.attributes.schema;
    displayText += '.';
    displayText += functionWithParameter.attributes.name;
    displayText += '(';
    displayText += functionWithParameter.attributes.parameters.map(function(parameter) {
      return [parameter.attributes.name, parameter.attributes.argumentType].join(' ');
    }).join(', ');
    displayText += ')';
    functionWithParameter.attributes.displayText = displayText;
  };

  function init() {
    module.controller('pgApexApp.region.AddButtonController', ['$scope', 'databaseService', 'formErrorService',
      AddButtonController]);
  }

  init();
})(window);