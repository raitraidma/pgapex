'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.workspace');

  function WorkspacesController($scope, workspaceService, helperService) {
    this.$scope = $scope;
    this.workspaceService = workspaceService;
    this.helperService = helperService;

    this.init();
    $scope.deleteWorkspace = this.deleteWorkspace.bind(this);
    $scope.pageChanged = this.selectVisibleWorkspaces.bind(this);
  }

  WorkspacesController.prototype.init = function() {
    this.$scope.itemsPerPage = 10;
    this.$scope.currentPage = 1;
    this.$scope.allWorkspaces = [];
    this.$scope.workspaces = [];
    this.loadWorkspaces();
  };

  WorkspacesController.prototype.loadWorkspaces = function() {
    this.workspaceService.getWorkspaces().then(function (response) {
      this.$scope.allWorkspaces = response.getDataOrDefault([]);
      this.selectVisibleWorkspaces();
    }.bind(this));
  };

  WorkspacesController.prototype.selectVisibleWorkspaces = function() {
    var start = (this.$scope.currentPage - 1) * this.$scope.itemsPerPage;
    var end = start + this.$scope.itemsPerPage;
    this.$scope.workspaces = this.$scope.allWorkspaces.slice(start, end);
  };

  WorkspacesController.prototype.deleteWorkspace = function(workspaceId) {
    this.helperService.confirm('workspace.deleteWorkspace',
                               'workspace.areYouSureThatYouWantToDeleteThisWorkspace',
                               'workspace.deleteWorkspace',
                               'workspace.cancel')
    .result.then(this.sendDeleteRequest(workspaceId).bind(this));
  };

  WorkspacesController.prototype.sendDeleteRequest = function(workspaceId) {
    return function() {
      return this.workspaceService.deleteWorkspace(workspaceId).then(this.loadWorkspaces.bind(this));
    };
  };

  function init() {
    module.controller('pgApexApp.workspace.WorkspacesController',
      ['$scope', 'workspaceService', 'helperService', WorkspacesController]);
  }

  init();
})(window);