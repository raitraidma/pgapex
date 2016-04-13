'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.workspace');

  function ManageWorkspaceController($scope, $location, $routeParams, workspaceService, userService, databaseService, formErrorService) {
    this.$scope = $scope;
    this.$location = $location;
    this.$routeParams = $routeParams;
    this.workspaceService = workspaceService;
    this.userService = userService;
    this.databaseService = databaseService;
    this.formErrorService = formErrorService;

    this.init();
  }

  ManageWorkspaceController.prototype.init = function() {
    this.$scope.mode = this.isCreatePage() ? 'create' : 'edit';
    this.$scope.schemas = [];
    this.$scope.users = [];
    this.$scope.workspace = {};
    this.$scope.formError = this.formErrorService.empty();

    this.$scope.saveWorkspace = this.saveWorkspace.bind(this);

    this.initSchemas();
    this.initUsers();
    this.loadWorkspace();
  };

  ManageWorkspaceController.prototype.loadWorkspace = function() {
    if (!this.isEditPage()) { return; }
    this.workspaceService.getWorkspace(this.getWorkspaceId()).then(function (response) {
      this.$scope.workspace = response.getDataOrDefault({});
    }.bind(this));
  };

  ManageWorkspaceController.prototype.initSchemas = function() {
    this.databaseService.getSchemas().then(function (response) {
      this.$scope.schemas = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageWorkspaceController.prototype.initUsers = function() {
    this.userService.getUsers().then(function (response) {
      this.$scope.users = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageWorkspaceController.prototype.isCreatePage = function() {
    return this.$location.path().endsWith('/create');
  };

  ManageWorkspaceController.prototype.isEditPage = function() {
    return this.$location.path().endsWith('/edit');
  };

  ManageWorkspaceController.prototype.saveWorkspace = function() {
    this.workspaceService.saveWorkspace(
      this.getWorkspaceId(),
      this.$scope.workspace.name,
      this.$scope.workspace.schemas,
      this.$scope.workspace.administrators
    ).then(this.handleSaveResponse.bind(this));
  };

  ManageWorkspaceController.prototype.getWorkspaceId = function() {
    return this.$routeParams.workspaceId || null;
  };

  ManageWorkspaceController.prototype.handleSaveResponse = function(response) {
    if (!response.hasErrors()) {
      this.$location.path('/administration/workspaces');
      return;
    } else {
      this.$scope.formError = this.formErrorService.parseApiResponse(response);
    }
  };

  function init() {
    module.controller('pgApexApp.workspace.ManageWorkspaceController',
      ['$scope', '$location', '$routeParams', 'workspaceService', 'userService',
       'databaseService', 'formErrorService', ManageWorkspaceController]);
  }

  init();
})(window);