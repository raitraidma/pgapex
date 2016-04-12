'use strict';
(function (window) {
  var angular = window.angular;

  function routeProviderConfig ($routeProvider) {
    $routeProvider
    .when('/application-builder/app/:applicationId/pages', {
      controller: 'pgApexApp.page.PagesController',
      templateUrl: 'app/partials/page/pages.html'
    })
    .when('/application-builder/app/:applicationId/pages/create', {
      controller: 'pgApexApp.page.CreatePageController',
      templateUrl: 'app/partials/page/create-page.html'
    });
  }

  function translatePartialLoaderProviderConfig($translatePartialLoaderProvider) {
    $translatePartialLoaderProvider.addPart('page');
  }

  function init() {
    angular
    .module('pgApexApp.page', ['pgApexApp'])
    .config(['$routeProvider', routeProviderConfig])
    .config(['$translatePartialLoaderProvider', translatePartialLoaderProviderConfig]);
  }

  init();
})(window);