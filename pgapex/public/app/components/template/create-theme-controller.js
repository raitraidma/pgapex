'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.template');

  function CreateThemeController($scope, templateService) {
    $scope.createTheme = function() {
      console.log('CreateTheme()');
    };
  }

  function init() {
    module.controller('pgApexApp.template.CreateThemeController', ['$scope', 'templateService', CreateThemeController]);
  }

  init();
})(window);