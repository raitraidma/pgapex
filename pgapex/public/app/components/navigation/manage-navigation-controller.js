'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.navigation');

  function ManageNavigationController($scope, $location, $routeParams, navigationService, formErrorService) {
    this.$scope = $scope;
    this.$location = $location;
    this.$routeParams = $routeParams;
    this.navigationService = navigationService;
    this.formErrorService = formErrorService;

    this.init();
  }

  ManageNavigationController.prototype.init = function() {
    this.$scope.mode = this.isCreatePage() ? 'create' : 'edit';
    this.$scope.navigation = {};
    this.$scope.formError = this.formErrorService.empty();

    this.$scope.saveNavigation = this.saveNavigation.bind(this);
    this.loadNavigation();
  };

  ManageNavigationController.prototype.isCreatePage = function() {
    return this.$location.path().endsWith('/create');
  };

  ManageNavigationController.prototype.isEditPage = function() {
    return this.$location.path().endsWith('/edit');
  };

  ManageNavigationController.prototype.getApplicationId = function() {
    return this.$routeParams.applicationId || null;
  };
  
  ManageNavigationController.prototype.getNavigationId = function() {
    return this.$routeParams.navigationId || null;
  };

  ManageNavigationController.prototype.saveNavigation = function() {
    this.navigationService.saveNavigation(
      this.getApplicationId(),
      this.getNavigationId(),
      this.$scope.navigation.name
    ).then(this.handleSaveResponse.bind(this));
  };

  ManageNavigationController.prototype.handleSaveResponse = function(response) {
    if (!response.hasErrors()) {
      this.$location.path('/application-builder/app/' + this.getApplicationId() + '/navigations');
      return;
    } else {
      this.$scope.formError = this.formErrorService.parseApiResponse(response);
    }
  };

  ManageNavigationController.prototype.loadNavigation = function() {
    if (!this.isEditPage()) { return; }
    this.navigationService.getNavigation(this.getNavigationId()).then(function (response) {
      this.$scope.navigation = response.getDataOrDefault({});
    }.bind(this));
  };

  function init() {
    module.controller('pgApexApp.navigation.ManageNavigationController',
      ['$scope', '$location', '$routeParams', 'navigationService',
      'formErrorService', ManageNavigationController]);
  }

  init();
})(window);