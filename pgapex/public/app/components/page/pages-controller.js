 'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.page');

  function PagesController($scope, $routeParams, pageService, helperService) {
    this.$scope = $scope;
    this.$routeParams = $routeParams;
    this.pageService = pageService;
    this.helperService = helperService;

    this.init();
    $scope.deletePage = this.deletePage.bind(this);
    $scope.pageChanged = this.selectVisiblePages.bind(this);
  }

  PagesController.prototype.init = function() {
    this.$scope.itemsPerPage = 10;
    this.$scope.currentPage = 1;
    this.$scope.routeParams = this.$routeParams;
    this.$scope.allPages = [];
    this.$scope.pages= [];

    this.loadPages();
  };

  PagesController.prototype.getApplicationId = function() {
    return this.$routeParams.applicationId || null;
  };

  PagesController.prototype.loadPages = function() {
    this.pageService.getPages(this.getApplicationId()).then(function (response) {
      this.$scope.allPages = response.hasData() ? response.getData() : [];
      this.selectVisiblePages();
    }.bind(this));
  };
  
  PagesController.prototype.selectVisiblePages = function() {
    var start = (this.$scope.currentPage - 1) * this.$scope.itemsPerPage;
    var end = start + this.$scope.itemsPerPage;
    this.$scope.pages = this.$scope.allPages.slice(start, end);
  };

  PagesController.prototype.deletePage = function(pageId) {
    this.helperService.confirm('page.deletePage',
                               'page.areYouSureThatYouWantToDeleteThisPage',
                               'page.deletePage',
                               'page.cancel')
    .result.then(this.sendDeleteRequest(pageId).bind(this));
  };

  PagesController.prototype.sendDeleteRequest = function(pageId) {
    return function() {
      return this.pageService.deletePage(pageId).then(this.loadPages.bind(this));
    };
  };

  function init() {
    module.controller('pgApexApp.page.PagesController', ['$scope', '$routeParams', 'pageService', 'helperService', PagesController]);
  }

  init();
})(window);