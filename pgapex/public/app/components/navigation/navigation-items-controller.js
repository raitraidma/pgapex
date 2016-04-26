 'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.navigation');

  function NavigationItemsController($scope, $routeParams, navigationService, helperService) {
    this.$scope = $scope;
    this.$routeParams = $routeParams;
    this.navigationService = navigationService;
    this.helperService = helperService;

    this.init();
    $scope.deleteNavigationItem = this.deleteNavigationItem.bind(this);
  }

  NavigationItemsController.prototype.init = function() {
    this.$scope.routeParams = this.$routeParams;
    this.$scope.navigationItems= [];
    this.loadNavigationItems();
  };

  NavigationItemsController.prototype.getNavigationId = function() {
    return this.$routeParams.navigationId ? this.$routeParams.navigationId : null;
  };

  NavigationItemsController.prototype.loadNavigationItems = function() {
    this.navigationService.getNavigationItems(this.getNavigationId()).then(function (response) {
      var navigationItems = response.getDataOrDefault([]).map(function (navigationItem) {
        var navItem =  navigationItem.attributes;
        navItem.id = navigationItem.id;
        return navItem;
      });
      this.$scope.navigationItems = this.navigationService.createStructuralNavigationList(navigationItems);
    }.bind(this));
  };

  NavigationItemsController.prototype.deleteNavigationItem = function(navigationItemId) {
    this.helperService.confirm('navigation.deleteNavigationItem',
                               'navigation.areYouSureThatYouWantToDeleteThisNavigationItem',
                               'navigation.deleteNavigationItem',
                               'navigation.cancel')
    .result.then(this.sendDeleteRequest(navigationItemId).bind(this));
  };

  NavigationItemsController.prototype.sendDeleteRequest = function(navigationItemId) {
    return function() {
      return this.navigationService.deleteNavigationItem(navigationItemId).then(this.loadNavigationItems.bind(this));
    };
  };

  function init() {
    module.controller('pgApexApp.navigation.NavigationItemsController',
      ['$scope', '$routeParams', 'navigationService', 'helperService', NavigationItemsController]);
  }

  init();
})(window);