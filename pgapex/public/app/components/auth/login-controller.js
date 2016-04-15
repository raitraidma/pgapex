'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.auth');

  function LoginController($scope, $location, authService, formErrorService) {
    $scope.formError = formErrorService.empty();

    $scope.login = function() {
      authService.login($scope.auth.login.username, $scope.auth.login.password)
      .then(function(response) {
        if (!response.hasErrors()) {
          $location.path('/application-builder/applications');
          return;
        } else {
          $scope.formError = formErrorService.parseApiResponse(response);
        }
      });
    }
  }

  function init() {
    module.controller('pgApexApp.auth.LoginController', ['$scope', '$location', 'authService', 'formErrorService', LoginController]);
  }

  init();
})(window);