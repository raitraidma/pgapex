'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.page');

  function PagesController($scope, $routeParams, pageService) {
    var applicationId = $routeParams.applicationId;
    $scope.applicationId = applicationId;

    pageService.getPages(applicationId).then(function (response) {
      $scope.pages = response.hasData() ? response.getData() : [];
    });
  }

  function init() {
    module.controller('pgApexApp.page.PagesController', ['$scope', '$routeParams', 'pageService', PagesController]);
  }

  init();
})(window);