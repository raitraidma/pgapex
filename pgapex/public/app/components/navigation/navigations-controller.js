 'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.navigation');

  function NavigationsController($scope, $routeParams, navigationService, helperService) {
    this.$scope = $scope;
    this.$routeParams = $routeParams;
    this.navigationService = navigationService;
    this.helperService = helperService;

    this.init();
    $scope.deleteNavigation = this.deleteNavigation.bind(this);
    $scope.pageChanged = this.selectVisibleNavigations.bind(this);
  }

  NavigationsController.prototype.init = function() {
    this.$scope.itemsPerPage = 10;
    this.$scope.currentPage = 1;
    this.$scope.routeParams = this.$routeParams;
    this.$scope.allNavigations = [];
    this.$scope.navigations= [];

    this.loadNavigations();
  };

  NavigationsController.prototype.getApplicationId = function() {
    return this.$routeParams.applicationId || null;
  };

  NavigationsController.prototype.loadNavigations = function() {
    this.navigationService.getNavigations(this.getApplicationId()).then(function (response) {
      this.$scope.allNavigations = response.hasData() ? response.getData() : [];
      this.selectVisibleNavigations();
    }.bind(this));
  };
  
  NavigationsController.prototype.selectVisibleNavigations = function() {
    var start = (this.$scope.currentPage - 1) * this.$scope.itemsPerPage;
    var end = start + this.$scope.itemsPerPage;
    this.$scope.navigations = this.$scope.allNavigations.slice(start, end);
  };

  NavigationsController.prototype.deleteNavigation = function(navigationId) {
    this.helperService.confirm('navigation.deleteNavigation',
                               'navigation.areYouSureThatYouWantToDeleteThisNavigation',
                               'navigation.deleteNavigation',
                               'navigation.cancel')
    .result.then(this.sendDeleteRequest(navigationId).bind(this));
  };

  NavigationsController.prototype.sendDeleteRequest = function(navigationId) {
    return function() {
      return this.navigationService.deleteNavigation(navigationId).then(this.loadNavigations.bind(this));
    };
  };

  function init() {
    module.controller('pgApexApp.navigation.NavigationsController', ['$scope', '$routeParams', 'navigationService', 'helperService', NavigationsController]);
  }

  init();
})(window);