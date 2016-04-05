'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.application');

  function EditApplicationController($scope, $location, $routeParams, applicationService, formErrorService) {
    var applicationId = $routeParams.applicationId;
    this.initScopeVariables($scope, applicationService, formErrorService);
    this.loadApplicationData(applicationId, applicationService, this.initApplicationData.bind($scope));
    this.loadSchemas(applicationService, this.initSchemas.bind($scope));
    this.loadAuthenticationFunctions(applicationService, this.initAuthenticationFunctions.bind($scope));

    $scope.saveApplication = function() {
      applicationService.saveApplication(
        applicationId,
        $scope.application.name,
        $scope.application.alias,
        $scope.application.schema,
        $scope.application.authenticationScheme,
        $scope.application.authenticationFunction
      ).then(function(response) {
        if (!response.hasErrors()) {
          $scope.formError = formErrorService.empty();
          $location.path('/application-builder/applications/' + applicationId + '/edit');
          return;
        } else {
          $scope.formError = formErrorService.parseApiResponse(response);
        }
      });
    };
  }

  EditApplicationController.prototype.initScopeVariables = function($scope, applicationService, formErrorService) {
    $scope.mode = 'edit';
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

  EditApplicationController.prototype.loadApplicationData = function(applicationId, applicationService, onLoad) {
    applicationService.getApplication(applicationId).then(function (response) {
      onLoad(response.getData());
    });
  };

  EditApplicationController.prototype.initApplicationData = function(applicationData) {
    this.application.name = applicationData.name;
    this.application.alias = applicationData.alias;
    this.application.schema = applicationData.schema;
    this.application.authenticationScheme = applicationData.authenticationScheme;
    this.application.authenticationFunction = applicationData.authenticationFunction;
  };

  EditApplicationController.prototype.loadSchemas = function(applicationService, onLoad) {
    applicationService.getSchemas().then(function (response) {
      onLoad(response.getDataOrDefault([]));
    });
  };

  EditApplicationController.prototype.initSchemas = function(loadedSchemas) {
    this.schemas = loadedSchemas;
  };

  EditApplicationController.prototype.loadAuthenticationFunctions = function(applicationService, onLoad) {
    applicationService.getAuthenticationFunctions().then(function (response) {
      onLoad(response.getDataOrDefault([]));
    });
  };

  EditApplicationController.prototype.initAuthenticationFunctions = function(loadedAuthenticationFunctions) {
    this.authenticationFunctions = loadedAuthenticationFunctions;
  };

  function init() {
    module.controller('pgApexApp.application.EditApplicationController',
      ['$scope', '$location', '$routeParams', 'applicationService', 'formErrorService', EditApplicationController]);
  }

  init();
})(window);