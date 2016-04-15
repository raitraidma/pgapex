'use strict';
(function (window) {
  var angular = window.angular;

  function routeProviderConfig ($routeProvider) {
    $routeProvider
    .when('/application-builder/app/:applicationId/navigations', {
      controller: 'pgApexApp.navigation.NavigationsController',
      templateUrl: 'app/partials/navigation/navigations.html'
    })
    .when('/application-builder/app/:applicationId/navigations/create', {
      controller: 'pgApexApp.navigation.ManageNavigationController',
      templateUrl: 'app/partials/navigation/manage-navigation.html'
    })
    .when('/application-builder/app/:applicationId/navigations/:navigationId/edit', {
      controller: 'pgApexApp.navigation.ManageNavigationController',
      templateUrl: 'app/partials/navigation/manage-navigation.html'
    })
    .when('/application-builder/app/:applicationId/navigations/:navigationId/items', {
      controller: 'pgApexApp.navigation.NavigationItemsController',
      templateUrl: 'app/partials/navigation/navigation-items.html'
    })
    .when('/application-builder/app/:applicationId/navigations/:navigationId/items/create', {
      controller: 'pgApexApp.navigation.ManageNavigationItemController',
      templateUrl: 'app/partials/navigation/manage-navigation-item.html'
    })
    .when('/application-builder/app/:applicationId/navigations/:navigationId/items/:navigationItemId/edit', {
      controller: 'pgApexApp.navigation.ManageNavigationItemController',
      templateUrl: 'app/partials/navigation/manage-navigation-item.html'
    });
  }

  function translatePartialLoaderProviderConfig($translatePartialLoaderProvider) {
    $translatePartialLoaderProvider.addPart('navigation');
  }

  function init() {
    angular
    .module('pgApexApp.navigation', ['pgApexApp'])
    .config(['$routeProvider', routeProviderConfig])
    .config(['$translatePartialLoaderProvider', translatePartialLoaderProviderConfig]);
  }

  init();
})(window);