'use strict';
(function (window) {
  var angular = window.angular;

  function routeProviderConfig ($routeProvider) {
    $routeProvider
    .when('/application-builder/applications', {
      controller: 'pgApexApp.application.ApplicationsController',
      templateUrl: 'app/partials/application/applications.html'
    })
    .when('/application-builder/applications/create', {
      controller: 'pgApexApp.application.CreateApplicationController',
      templateUrl: 'app/partials/application/application.html'
    })
    .when('/application-builder/applications/:applicationId/edit', {
      controller: 'pgApexApp.application.EditApplicationController',
      templateUrl: 'app/partials/application/application.html'
    });
  }

  function init() {
    angular
    .module('pgApexApp.application', ['pgApexApp'])
    .config(['$routeProvider', routeProviderConfig]);
  }

  init();
})(window);