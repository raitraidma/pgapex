'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.workspace');

  function WorkspacesController($scope, $uibModal, workspaceService, helperService) {
    this.$scope = $scope;
    this.$uibModal = $uibModal;
    this.workspaceService = workspaceService;
    this.helperService = helperService;

    this.init();
    $scope.deleteWorkspace = this.deleteWorkspace.bind(this);
  }

  WorkspacesController.prototype.init = function() {
    this.$scope.workspaces = [];
    this.loadWorkspaces();
  }

  WorkspacesController.prototype.loadWorkspaces = function() {
    this.workspaceService.getWorkspaces().then(function (response) {
      this.$scope.workspaces = response.getDataOrDefault([]);
    }.bind(this));
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
      ['$scope', '$uibModal', 'workspaceService', 'helperService', WorkspacesController]);
  }

  init();
})(window);