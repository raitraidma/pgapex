'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.page');

  function CreatePageController($scope, $routeParams, pageService) {
    $scope.routeParams = $routeParams;
  }

  function init() {
    module.controller('pgApexApp.page.CreatePageController', ['$scope', '$routeParams', 'pageService', CreatePageController]);
  }

  init();
})(window);