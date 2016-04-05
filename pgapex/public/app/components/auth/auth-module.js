'use strict';
(function (window) {
  var angular = window.angular;

  function routeProviderConfig ($routeProvider) {
    $routeProvider
    .when('/login', {
      controller: 'pgApexApp.auth.LoginController',
      templateUrl: 'app/partials/auth/login.html'
    })
    .when('/logout', {
      controller: 'pgApexApp.auth.LogoutController',
      template: ''
    });
  }

  function init() {
    angular
    .module('pgApexApp.auth', ['pgApexApp'])
    .config(['$routeProvider', routeProviderConfig]);
  }

  init();
})(window);