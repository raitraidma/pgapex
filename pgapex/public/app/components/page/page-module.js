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
      controller: 'pgApexApp.page.ManagePageController',
      templateUrl: 'app/partials/page/manage-page.html'
    })
    .when('/application-builder/app/:applicationId/pages/:pageId/edit', {
      controller: 'pgApexApp.page.ManagePageController',
      templateUrl: 'app/partials/page/manage-page.html'
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