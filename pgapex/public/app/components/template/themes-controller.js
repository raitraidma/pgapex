'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.template');

  function ThemesController($scope, $routeParams, templateService) {
    var applicationId = $routeParams.applicationId;
    $scope.applicationId = applicationId;
    
    templateService.getThemes(applicationId).then(function (response) {
      $scope.themes = response.hasData() ? response.getData() : [];
    });
  }

  function init() {
    module.controller('pgApexApp.template.ThemesController', ['$scope', '$routeParams', 'templateService', ThemesController]);
  }

  init();
})(window);