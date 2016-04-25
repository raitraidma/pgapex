'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.application');

  function ManageApplicationAuthenticationController($scope, $location, $routeParams, applicationService,
                                      databaseService, templateService, formErrorService) {
    this.$scope = $scope;
    this.$location = $location;
    this.$routeParams = $routeParams;
    this.applicationService = applicationService;
    this.databaseService = databaseService;
    this.templateService = templateService;
    this.formErrorService = formErrorService;

    this.init();
  }

  ManageApplicationAuthenticationController.prototype.init = function() {
    this.$scope.application = {};
    this.$scope.formError = this.formErrorService.empty();
    this.$scope.authenticationFunctions = [];
    this.$scope.loginPageTemplates = [];

    this.$scope.saveApplicationAuthentication = this.saveApplicationAuthentication.bind(this);
    this.$scope.trackAuthenticationFunction = function(authenticationFunction) {
      if (!authenticationFunction) { return authenticationFunction; }
      return (authenticationFunction.database + '.'
            + authenticationFunction.schema + '.'
            + authenticationFunction.function);
    }

    this.initLoginPageTemplates();
    this.initAuthenticationFunctions();
    this.loadApplication();
  };

  ManageApplicationAuthenticationController.prototype.getApplicationId = function() {
    return this.$routeParams.applicationId || null;
  };

  ManageApplicationAuthenticationController.prototype.initAuthenticationFunctions = function() {
    this.databaseService.getAuthenticationFunctions(this.getApplicationId()).then(function (response) {
      this.$scope.authenticationFunctions = response.getDataOrDefault([]).map(function(functionData) {
        return functionData.attributes;
      });
    }.bind(this));
  };

  ManageApplicationAuthenticationController.prototype.initLoginPageTemplates = function() {
    this.templateService.getLoginTemplates().then(function (response) {
      this.$scope.loginPageTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageApplicationAuthenticationController.prototype.loadApplication = function() {
    this.applicationService.getApplicationAuthentication(this.getApplicationId()).then(function (response) {
      this.$scope.application = response.getDataOrDefault({'attributes':{}}).attributes;
    }.bind(this));
  };

  ManageApplicationAuthenticationController.prototype.saveApplicationAuthentication = function() {
    this.applicationService.saveApplicationAuthentication(
      this.getApplicationId(),
      this.$scope.application.authenticationScheme,
      this.$scope.application.authenticationFunction,
      this.$scope.application.loginPageTemplate
    ).then(this.handleSaveResponse.bind(this));
  };

  ManageApplicationAuthenticationController.prototype.handleSaveResponse = function(response) {
    if (!response.hasErrors()) {
      this.$location.path('/application-builder/applications');
      return;
    } else {
      this.$scope.formError = this.formErrorService.parseApiResponse(response);
    }
  };

  function init() {
    module.controller('pgApexApp.application.ManageApplicationAuthenticationController',
      ['$scope', '$location', '$routeParams', 'applicationService', 'databaseService',
      'templateService', 'formErrorService', ManageApplicationAuthenticationController]);
  }

  init();
})(window);