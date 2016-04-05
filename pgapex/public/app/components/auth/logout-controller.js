'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.auth');

  function LogoutController($scope, $location, authService) {
    authService.logout().then(function() {
      $location.path('/login');
    });
  }

  function init() {
    module.controller('pgApexApp.auth.LogoutController', ['$scope', '$location', 'authService', LogoutController]);
  }

  init();
})(window);