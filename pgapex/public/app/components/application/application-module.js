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
      controller: 'pgApexApp.application.ManageApplicationController',
      templateUrl: 'app/partials/application/manage-application.html'
    })
    .when('/application-builder/applications/:applicationId/edit', {
      controller: 'pgApexApp.application.ManageApplicationController',
      templateUrl: 'app/partials/application/manage-application.html'
    })
    .when('/application-builder/applications/:applicationId/authentication', {
      controller: 'pgApexApp.application.ManageApplicationAuthenticationController',
      templateUrl: 'app/partials/application/manage-application-authentication.html'
    });
  }

  function translatePartialLoaderProviderConfig($translatePartialLoaderProvider) {
    $translatePartialLoaderProvider.addPart('application');
  }

  function init() {
    angular
    .module('pgApexApp.application', ['pgApexApp'])
    .config(['$routeProvider', routeProviderConfig])
    .config(['$translatePartialLoaderProvider', translatePartialLoaderProviderConfig]);
  }

  init();
})(window);