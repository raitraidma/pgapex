'use strict';
(function (window) {
  var angular = window.angular;

  function routeProviderConfig ($routeProvider) {
    $routeProvider
    .when('/administration/users', {
      controller: 'pgApexApp.user.UsersController',
      templateUrl: 'app/partials/user/users.html'
    })
    .when('/administration/users/create', {
      controller: 'pgApexApp.user.ManageUserController',
      templateUrl: 'app/partials/user/manage-user.html'
    })
    .when('/administration/users/:userId/edit', {
      controller: 'pgApexApp.user.ManageUserController',
      templateUrl: 'app/partials/user/manage-user.html'
    });
  }

  function translatePartialLoaderProviderConfig($translatePartialLoaderProvider) {
    $translatePartialLoaderProvider.addPart('user');
  }

  function init() {
    angular
    .module('pgApexApp.user', ['pgApexApp'])
    .config(['$routeProvider', routeProviderConfig])
    .config(['$translatePartialLoaderProvider', translatePartialLoaderProviderConfig]);
  }

  init();
})(window);