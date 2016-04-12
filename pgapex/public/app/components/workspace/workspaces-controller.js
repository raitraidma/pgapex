'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.workspace');

  function WorkspacesController($scope, workspaceService) {
    $scope.workspaces = [];

    function init() {
      workspaceService.getWorkspaces().then(function (response) {
        $scope.workspaces = response.getDataOrDefault([]);
      });
    }
    init();
  }

  function init() {
    module.controller('pgApexApp.workspace.WorkspacesController',
      ['$scope', 'workspaceService', WorkspacesController]);
  }

  init();
})(window);