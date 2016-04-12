'use strict';
(function (window) {
  var angular = window.angular;

  function routeProviderConfig ($routeProvider) {
    $routeProvider
    .when('/administration/workspaces', {
      controller: 'pgApexApp.workspace.WorkspacesController',
      templateUrl: 'app/partials/workspace/workspaces.html'
    })
    .when('/administration/workspaces/create', {
      controller: 'pgApexApp.workspace.ManageWorkspaceController',
      templateUrl: 'app/partials/workspace/manage-workspace.html'
    });
  }

  function translatePartialLoaderProviderConfig($translatePartialLoaderProvider) {
    $translatePartialLoaderProvider.addPart('workspace');
  }

  function init() {
    angular
    .module('pgApexApp.workspace', ['pgApexApp'])
    .config(['$routeProvider', routeProviderConfig])
    .config(['$translatePartialLoaderProvider', translatePartialLoaderProviderConfig]);
  }

  init();
})(window);