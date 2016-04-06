'use strict';
(function (window) {
  var angular = window.angular;
  var modules = ['pascalprecht.translate', 'ngRoute', 'pgApexApp.auth', 'pgApexApp.application', 'pgApexApp.page', 'pgApexApp.template'];

  function routeProviderConfig ($routeProvider) {
    $routeProvider
    .otherwise({ redirectTo: '/login' });
  }

  function translateProviderConfig ($translateProvider, $translatePartialLoaderProvider) {
    $translateProvider.useLoader('$translatePartialLoader', {
      urlTemplate: 'app/lang/{lang}/{part}.json'
    });
    $translateProvider.useSanitizeValueStrategy('escape');
    $translateProvider.preferredLanguage('en');
  }

  function loadPgApexApplication(angular) {
    angular
    .module('pgApexApp', modules)
    .config(['$routeProvider', routeProviderConfig])
    .config(['$translateProvider', '$translatePartialLoaderProvider', translateProviderConfig]);
  }

  function init() {
    window.document.addEventListener('DOMContentLoaded', (function() {
      loadPgApexApplication(angular);
    })(angular));
  }

  init();

})(window);