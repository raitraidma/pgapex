'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.application');

  function ManageApplicationController($scope, $location, $routeParams, applicationService,
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

  ManageApplicationController.prototype.init = function() {
    this.$scope.mode = this.isCreatePage() ? 'create' : 'edit';
    this.$scope.application = {
      "authenticationScheme": "NO_AUTHENTICATION"
    };
    this.$scope.formError = this.formErrorService.empty();
    this.$scope.databases = [];
    this.$scope.authenticationFunctions = [];
    this.$scope.loginPageTemplates = [];
    this.$scope.passwordFieldType = 'password';

    this.$scope.togglePasswordFieldType = this.togglePasswordFieldType.bind(this);
    this.$scope.saveApplication = this.saveApplication.bind(this);
    this.$scope.trackAuthenticationFunction = function(authenticationFunction) {
      if (!authenticationFunction) { return authenticationFunction; }
      return (authenticationFunction.database + '.'
            + authenticationFunction.schema + '.'
            + authenticationFunction.function);
    }

    this.initDatabases();
    this.initAuthenticationFunctions();
    this.initLoginPageTemplates();
    this.loadApplication();
  };

  ManageApplicationController.prototype.togglePasswordFieldType = function() {
    this.$scope.passwordFieldType = (this.$scope.passwordFieldType == 'text') ? 'password' : 'text';
  };

  ManageApplicationController.prototype.isCreatePage = function() {
    return this.$location.path().endsWith('/create');
  };

  ManageApplicationController.prototype.isEditPage = function() {
    return this.$location.path().endsWith('/edit');
  };

  ManageApplicationController.prototype.getApplicationId = function() {
    return this.$routeParams.applicationId || null;
  };

  ManageApplicationController.prototype.initDatabases = function() {
    this.databaseService.getDatabases().then(function (response) {
      this.$scope.databases = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageApplicationController.prototype.initAuthenticationFunctions = function() {
    this.databaseService.getAuthenticationFunctions().then(function (response) {
      this.$scope.authenticationFunctions = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageApplicationController.prototype.initLoginPageTemplates = function() {
    this.templateService.getLoginTemplates().then(function (response) {
      this.$scope.loginPageTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageApplicationController.prototype.initUsers = function() {
    this.userService.getUsers().then(function (response) {
      this.$scope.users = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageApplicationController.prototype.loadApplication = function() {
    if (!this.isEditPage()) { return; }
    this.applicationService.getApplication(this.getApplicationId()).then(function (response) {
      this.$scope.application = response.getDataOrDefault({});
    }.bind(this));
  };

  ManageApplicationController.prototype.saveApplication = function() {
    this.applicationService.saveApplication(
      this.getApplicationId(),
      this.$scope.application.name,
      this.$scope.application.alias,
      this.$scope.application.database,
      this.$scope.application.authenticationScheme,
      this.$scope.application.authenticationFunction,
      this.$scope.application.loginPageTemplate,
      this.$scope.application.databaseUsername,
      this.$scope.application.databasePassword
    ).then(this.handleSaveResponse.bind(this));
  };

  ManageApplicationController.prototype.handleSaveResponse = function(response) {
    if (!response.hasErrors()) {
      this.$location.path('/application-builder/applications');
      return;
    } else {
      this.$scope.formError = this.formErrorService.parseApiResponse(response);
    }
  };

  function init() {
    module.controller('pgApexApp.application.ManageApplicationController',
      ['$scope', '$location', '$routeParams', 'applicationService', 'databaseService',
      'templateService', 'formErrorService', ManageApplicationController]);
  }

  init();
})(window);