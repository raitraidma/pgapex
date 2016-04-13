'use strict';
(function (window) {
  var angular = window.angular;
  var modules = ['pascalprecht.translate', 'frapontillo.bootstrap-duallistbox',
                'ui.bootstrap', 'ngRoute', 'pgApexApp.auth', 'pgApexApp.application',
                'pgApexApp.page', 'pgApexApp.template', 'pgApexApp.workspace', 'pgApexApp.user'];

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
    $translatePartialLoaderProvider.addPart('general');
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