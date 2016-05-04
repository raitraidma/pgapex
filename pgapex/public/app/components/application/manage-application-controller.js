'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.application');

  function ManageApplicationController($scope, $location, $routeParams, applicationService,
                                      databaseService, formErrorService, helperService) {
    this.$scope = $scope;
    this.$scope.helper = helperService;
    this.$location = $location;
    this.$routeParams = $routeParams;
    this.applicationService = applicationService;
    this.databaseService = databaseService;
    this.formErrorService = formErrorService;

    this.init();
  }

  ManageApplicationController.prototype.init = function() {
    this.$scope.mode = this.isCreatePage() ? 'create' : 'edit';
    this.$scope.application = {};
    this.$scope.formError = this.formErrorService.empty();
    this.$scope.databases = [];
    this.$scope.passwordFieldType = 'password';

    this.$scope.togglePasswordFieldType = this.togglePasswordFieldType.bind(this);
    this.$scope.saveApplication = this.saveApplication.bind(this);

    this.initDatabases();
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
    return this.$routeParams.applicationId ? parseInt(this.$routeParams.applicationId) : null;
  };

  ManageApplicationController.prototype.initDatabases = function() {
    this.databaseService.getDatabases().then(function (response) {
      this.$scope.databases = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageApplicationController.prototype.loadApplication = function() {
    if (!this.isEditPage()) { return; }
    this.applicationService.getApplication(this.getApplicationId()).then(function (response) {
      this.$scope.application = response.getDataOrDefault({'attributes':{}}).attributes;
    }.bind(this));
  };

  ManageApplicationController.prototype.saveApplication = function() {
    this.applicationService.saveApplication(
      this.getApplicationId(),
      this.$scope.application.name,
      this.$scope.application.alias || null,
      this.$scope.application.database,
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
        'formErrorService', 'helperService', ManageApplicationController]);
  }

  init();
})(window);