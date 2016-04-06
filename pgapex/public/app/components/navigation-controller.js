'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function NavigationController($scope, $location, $routeParams) {
    var path = $location.path();
    $scope.routeParams = $routeParams;

    $scope.isApplicationBuilderPage = function () {
      return path.startsWith('/application-builder');
    }

    $scope.isSettingsPage = function () {
      return path.startsWith('/settings');
    }

    $scope.isPagesPage = function () {
      return path.startsWith('/application-builder') && path.contains('/pages');
    }

    $scope.isNavigationPage = function () {
      return path.startsWith('/application-builder') && path.contains('/navigation');
    }

    $scope.isThemesPage = function () {
      return path.startsWith('/application-builder') && path.contains('/themes');
    }
  }

  function init() {
    module.controller('pgApexApp.NavigationController', ['$scope', '$location', '$routeParams', NavigationController]);
  }

  init();
})(window);