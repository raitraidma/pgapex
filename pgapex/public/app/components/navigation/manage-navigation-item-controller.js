'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.navigation');

  function ManageNavigationItemController($scope, $location, $routeParams, navigationService, pageService, formErrorService) {
    this.$scope = $scope;
    this.$location = $location;
    this.$routeParams = $routeParams;
    this.navigationService = navigationService;
    this.pageService = pageService;
    this.formErrorService = formErrorService;

    this.init();
  }

  ManageNavigationItemController.prototype.init = function() {
    this.$scope.mode = this.isCreatePage() ? 'create' : 'edit';
    this.$scope.navigationItem = {
      'target': 'PAGE'
    };
    this.$scope.pages = [];
    this.$scope.formError = this.formErrorService.empty();

    this.$scope.saveNavigationItem = this.saveNavigationItem.bind(this);

    this.initPages();
    this.initNavigationItems();
    this.loadNavigationItem();
  };

  ManageNavigationItemController.prototype.isCreatePage = function() {
    return this.$location.path().endsWith('/create');
  };

  ManageNavigationItemController.prototype.isEditPage = function() {
    return this.$location.path().endsWith('/edit');
  };

  ManageNavigationItemController.prototype.getNavigationItemId = function() {
    return this.$routeParams.navigationItemId ? this.$routeParams.navigationItemId : null;
  };
  
  ManageNavigationItemController.prototype.getNavigationId = function() {
    return this.$routeParams.navigationId ? parseInt(this.$routeParams.navigationId) : null;
  };
  
  ManageNavigationItemController.prototype.getApplicationId = function() {
    return this.$routeParams.applicationId ? this.$routeParams.applicationId : null;
  };

  ManageNavigationItemController.prototype.initPages = function() {
    this.pageService.getPages(this.getApplicationId()).then(function (response) {
      this.$scope.pages = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageNavigationItemController.prototype.initNavigationItems = function() {
    this.navigationService.getNavigationItems(this.getNavigationId()).then(function (response) {
      var navigationItems = response.getDataOrDefault([]).map(function (navigationItem) {
        var navItem =  navigationItem.attributes;
        navItem.id = navigationItem.id;
        return navItem;
      });
      this.$scope.navigationItems = this.navigationService.createStructuralNavigationList(navigationItems);
    }.bind(this));
  };

  ManageNavigationItemController.prototype.saveNavigationItem = function() {
    this.navigationService.saveNavigationItem(
      this.getNavigationId(),
      this.getNavigationItemId(),
      this.$scope.navigationItem.name,
      this.$scope.navigationItem.sequence,
      this.$scope.navigationItem.parentNavigationItemId || null,
      this.$scope.navigationItem.target === 'PAGE' ? this.$scope.navigationItem.page : null,
      this.$scope.navigationItem.target === 'URL' ? this.$scope.navigationItem.url : null
    ).then(this.handleSaveResponse.bind(this));
  };

  ManageNavigationItemController.prototype.handleSaveResponse = function(response) {
    if (!response.hasErrors()) {
      this.$location.path('/application-builder/app/' + this.getApplicationId()
                            + '/navigations/' + this.getNavigationId() + '/items');
      return;
    } else {
      this.$scope.formError = this.formErrorService.parseApiResponse(response);
    }
  };

  ManageNavigationItemController.prototype.loadNavigationItem = function() {
    if (!this.isEditPage()) { return; }
    this.navigationService.getNavigationItem(this.getNavigationItemId()).then(function (response) {
      this.$scope.navigationItem = response.getDataOrDefault({'attributes': {}}).attributes;
      this.$scope.navigationItem['target'] = this.$scope.navigationItem.page !== null ? 'PAGE' : 'URL';
      if (this.$scope.navigationItem.page !== null) {
        this.$scope.navigationItem.page += '';
      }
    }.bind(this));
  };

  function init() {
    module.controller('pgApexApp.navigation.ManageNavigationItemController',
      ['$scope', '$location', '$routeParams', 'navigationService',
      'pageService', 'formErrorService', ManageNavigationItemController]);
  }

  init();
})(window);