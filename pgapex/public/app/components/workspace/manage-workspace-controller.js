'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.workspace');

  function ManageWorkspaceController($scope, $location, workspaceService, userService, databaseService, formErrorService) {
    $scope.schemas = [];
    $scope.users = [];
    $scope.workspace = {};
    $scope.formError = formErrorService.empty();

    $scope.saveWorkspace = function() {
      workspaceService.saveWorkspace(
        null,
        $scope.workspace.name,
        $scope.workspace.schemas,
        $scope.workspace.administrators
      ).then(function(response) {
        if (!response.hasErrors()) {
          $location.path('/administration/workspaces');
          return;
        } else {
          $scope.formError = formErrorService.parseApiResponse(response);
        }
      });
    };

    function init() {
      databaseService.getSchemas().then(function (response) {
        $scope.schemas = response.getDataOrDefault([]);
      });
      userService.getUsers().then(function (response) {
        $scope.users = response.getDataOrDefault([]);
      });
    }
    init();
  }

  function init() {
    module.controller('pgApexApp.workspace.ManageWorkspaceController',
      ['$scope', '$location', 'workspaceService', 'userService',
       'databaseService', 'formErrorService', ManageWorkspaceController]);
  }

  init();
})(window);