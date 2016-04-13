'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.application');

  function ManageApplicationController($scope, $location, $routeParams, applicationService, userService, formErrorService) {
    this.$scope = $scope;
    this.$location = $location;
    this.$routeParams = $routeParams;
    this.applicationService = applicationService;
    this.userService = userService;
    this.formErrorService = formErrorService;

    this.init();
  }

  ManageApplicationController.prototype.init = function() {
    this.$scope.mode = this.isCreatePage() ? 'create' : 'edit';
    this.$scope.application = {
      "authenticationScheme": "DATABASE_USER"
    };
    this.$scope.formError = this.formErrorService.empty();
    this.$scope.schemas = [];
    this.$scope.authenticationFunctions = [];
    this.$scope.users = [];

    this.$scope.saveApplication = this.saveApplication.bind(this);

    this.initSchemas();
    this.initAuthenticationFunctions();
    this.initUsers();
    this.loadApplication();
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

  ManageApplicationController.prototype.initSchemas = function() {
    this.applicationService.getSchemas().then(function (response) {
      this.$scope.schemas = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageApplicationController.prototype.initAuthenticationFunctions = function() {
    this.applicationService.getAuthenticationFunctions().then(function (response) {
      this.$scope.authenticationFunctions = response.getDataOrDefault([]);
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
      this.$scope.application.schema,
      this.$scope.application.authenticationScheme,
      this.$scope.application.authenticationFunction,
      this.$scope.application.developers
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
      ['$scope', '$location', '$routeParams', 'applicationService', 'userService', 'formErrorService', ManageApplicationController]);
  }

  init();
})(window);