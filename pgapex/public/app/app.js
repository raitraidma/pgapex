'use strict';
(function (window) {
  var angular = window.angular;
  var modules = ['ngRoute', 'pgApexApp.auth', 'pgApexApp.application', 'pgApexApp.page', 'pgApexApp.template'];

  function routeProviderConfig ($routeProvider) {
    $routeProvider
    .otherwise({ redirectTo: '/login' });
  }

  function loadPgApexApplication(angular) {
    angular
    .module('pgApexApp', modules)
    .config(['$routeProvider', routeProviderConfig]);
  }

  function init() {
    window.document.addEventListener('DOMContentLoaded', (function() {
      loadPgApexApplication(angular);
    })(angular));
  }

  init();

})(window);