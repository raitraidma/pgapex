'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.application');

  function CreateApplicationController($scope, $location, applicationService, formErrorService) {
    this.initScopeVariables($scope, applicationService, formErrorService);
    this.loadSchemas(applicationService, this.initSchemas.bind($scope));
    this.loadAuthenticationFunctions(applicationService, this.initAuthenticationFunctions.bind($scope));

    $scope.saveApplication = function() {
      applicationService.saveApplication(
        null,
        $scope.application.name,
        $scope.application.alias,
        $scope.application.schema,
        $scope.application.authenticationScheme,
        $scope.application.authenticationFunction
      ).then(function(response) {
        if (!response.hasErrors()) {
          $location.path('/application-builder/applications');
          return;
        } else {
          $scope.formError = formErrorService.parseApiResponse(response);
        }
      });
    };
  }

  CreateApplicationController.prototype.initScopeVariables = function($scope, applicationService, formErrorService) {
    $scope.mode = 'create';
    $scope.application = {};
    $scope.application.name = '';
    $scope.application.alias = '';
    $scope.application.schema = '';
    $scope.application.authenticationScheme = 'none';
    $scope.application.authenticationFunction = '';

    $scope.schemas = [];
    $scope.authenticationFunctions = [];
    
    $scope.formError = formErrorService.empty();
  };

  CreateApplicationController.prototype.loadSchemas = function(applicationService, onLoad) {
    applicationService.getSchemas().then(function (response) {
      onLoad(response.getDataOrDefault([]));
    });
  };

  CreateApplicationController.prototype.loadAuthenticationFunctions = function(applicationService, onLoad) {
    applicationService.getAuthenticationFunctions().then(function (response) {
      onLoad(response.getDataOrDefault([]));
    });
  };

  CreateApplicationController.prototype.initSchemas = function(loadedSchemas) {
    this.schemas = loadedSchemas;
    this.application.schema = (loadedSchemas.length > 0) ? loadedSchemas[0] : '';
  };

  CreateApplicationController.prototype.initAuthenticationFunctions = function(loadedAuthenticationFunctions) {
    this.authenticationFunctions = loadedAuthenticationFunctions;
    this.application.authenticationFunction =
      (loadedAuthenticationFunctions.length > 0) ? loadedAuthenticationFunctions[0] : '';
  };

  function init() {
    module.controller('pgApexApp.application.CreateApplicationController',
      ['$scope', '$location', 'applicationService', 'formErrorService', CreateApplicationController]);
  }

  init();
})(window);