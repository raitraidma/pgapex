'use strict';
(function (window) {
  var angular = window.angular;
  var modules = ['pascalprecht.translate', 'frapontillo.bootstrap-duallistbox',
                'ui.bootstrap', 'ngRoute', 'pgApexApp.auth', 'pgApexApp.application',
                'pgApexApp.page', 'pgApexApp.template', 'pgApexApp.workspace',
                'pgApexApp.user', 'pgApexApp.navigation', 'pgApexApp.region'];

  function routeProviderConfig ($routeProvider, $locationProvider, $httpProvider) {
    $routeProvider
    .otherwise({ redirectTo: '/application-builder/applications' });

    var interceptor = ['$location', '$q', function($location, $q) {
      return {
        'responseError': function(response) {
          if(response.status === 401) {
            $location.path('/login');
            return $q.reject(response);
          } else {
            return $q.reject(response);
          }
        }
      };
    }];

    $httpProvider.interceptors.push(interceptor);
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
    .config(['$routeProvider', '$locationProvider', '$httpProvider', routeProviderConfig])
    .config(['$translateProvider', '$translatePartialLoaderProvider', translateProviderConfig]);
  }

  function init() {
    window.document.addEventListener('DOMContentLoaded', (function() {
      loadPgApexApplication(angular);
    })(angular));
  }

  init();

})(window);