'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.page');

  function ManageHtmlRegionController($scope, $location, $routeParams, regionService, templateService, formErrorService) {
    this.$scope = $scope;
    this.$location = $location;
    this.$routeParams = $routeParams;
    this.regionService = regionService;
    this.templateService = templateService;
    this.formErrorService = formErrorService;

    this.init();
  }

  ManageHtmlRegionController.prototype.init = function() {
    this.$scope.mode = this.isCreatePage() ? 'create' : 'edit';
    this.$scope.region = {};
    this.$scope.regionTemplates = [];
    this.$scope.formError = this.formErrorService.empty();
    
    this.$scope.saveRegion = this.saveRegion.bind(this);
    this.initRegionTemplates();
    this.loadRegion();
  };

  ManageHtmlRegionController.prototype.initRegionTemplates = function() {
    this.templateService.getRegionTemplates().then(function (response) {
      this.$scope.regionTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageHtmlRegionController.prototype.isCreatePage = function() {
    return this.$location.path().endsWith('/create');
  };

  ManageHtmlRegionController.prototype.isEditPage = function() {
    return this.$location.path().endsWith('/edit');
  };

  ManageHtmlRegionController.prototype.getDisplayPoint = function() {
    return this.$routeParams.displayPoint || null;
  };
  
  ManageHtmlRegionController.prototype.getPageId = function() {
    return this.$routeParams.pageId || null;
  };
  
  ManageHtmlRegionController.prototype.getRegionId = function() {
    return this.$routeParams.regionId || null;
  };
  
  ManageHtmlRegionController.prototype.getApplicationId = function() {
    return this.$routeParams.applicationId || null;
  };

  ManageHtmlRegionController.prototype.saveRegion = function() {
    this.regionService.saveHtmlRegion(
      this.getPageId(),
      this.getDisplayPoint(),
      this.getRegionId(),
      this.$scope.region.name,
      this.$scope.region.sequence,
      this.$scope.region.regionTemplate,
      this.$scope.region.isVisible,
      this.$scope.region.content
    ).then(this.handleSaveResponse.bind(this));
  };

  ManageHtmlRegionController.prototype.handleSaveResponse = function(response) {
    if (!response.hasErrors()) {
      this.$location.path('/application-builder/app/' + this.getApplicationId()
                        + '/pages/' + this.getPageId() + '/regions');
      return;
    } else {
      this.$scope.formError = this.formErrorService.parseApiResponse(response);
    }
  };

  ManageHtmlRegionController.prototype.loadRegion = function() {
    if (!this.isEditPage()) { return; }
    this.regionService.getHtmlRegion(this.getRegionId()).then(function (response) {
      this.$scope.region = response.getDataOrDefault({});
    }.bind(this));
  };

  function init() {
    module.controller('pgApexApp.region.ManageHtmlRegionController',
      ['$scope', '$location', '$routeParams', 'regionService',
      'templateService', 'formErrorService', ManageHtmlRegionController]);
  }

  init();
})(window);