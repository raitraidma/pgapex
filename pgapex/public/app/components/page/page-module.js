'use strict';
(function (window) {
  var angular = window.angular;

  function routeProviderConfig ($routeProvider) {
    $routeProvider
    .when('/application-builder/app/:applicationId/pages', {
      controller: 'pgApexApp.page.PagesController',
      templateUrl: 'app/partials/page/pages.html'
    });
  }

  function init() {
    angular
    .module('pgApexApp.page', ['pgApexApp'])
    .config(['$routeProvider', routeProviderConfig]);
  }

  init();
})(window);