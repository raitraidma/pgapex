'use strict';
(function (window) {
  var angular = window.angular;

  function routeProviderConfig ($routeProvider) {
    $routeProvider
    .when('/application-builder/app/:applicationId/themes', {
      controller: 'pgApexApp.template.ThemesController',
      templateUrl: 'app/partials/template/themes.html'
    })
    .when('/application-builder/app/:applicationId/themes/create', {
      controller: 'pgApexApp.template.CreateThemeController',
      templateUrl: 'app/partials/template/create-theme.html'
    })
    .when('/application-builder/app/:applicationId/themes/:themeId/templates', {
      controller: 'pgApexApp.template.TemplatesController',
      templateUrl: 'app/partials/template/templates.html'
    });
  }

  function translatePartialLoaderProviderConfig($translatePartialLoaderProvider) {
    $translatePartialLoaderProvider.addPart('template');
  }

  function init() {
    angular
    .module('pgApexApp.template', ['pgApexApp'])
    .config(['$routeProvider', routeProviderConfig])
    .config(['$translatePartialLoaderProvider', translatePartialLoaderProviderConfig]);
  }

  init();
})(window);