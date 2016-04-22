'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.page');

  function ManageReportRegionController($scope, $location, $routeParams, regionService,
                                        templateService, databaseService, formErrorService) {
    this.$scope = $scope;
    this.$location = $location;
    this.$routeParams = $routeParams;
    this.regionService = regionService;
    this.templateService = templateService;
    this.databaseService = databaseService;
    this.formErrorService = formErrorService;

    this.init();
  }

  ManageReportRegionController.prototype.init = function() {
    this.$scope.mode = this.isCreatePage() ? 'create' : 'edit';
    this.$scope.region = {
      'showHeader': true,
      'itemsPerPage': 15,
      'reportColumns': []
    };
    this.$scope.viewColumns = [];
    this.$scope.regionTemplates = [];
    this.$scope.reportTemplates = [];
    this.$scope.viewsWithColumns = [];
    this.$scope.formError = this.formErrorService.empty();
    
    this.$scope.addReportColumn = this.addReportColumn.bind(this);
    this.$scope.deleteReportColumn = this.deleteReportColumn.bind(this);
    this.$scope.changeViewColumns = this.changeViewColumns.bind(this);
    this.$scope.saveRegion = this.saveRegion.bind(this);
    this.initRegionTemplates();
    this.initReportTemplates();
    this.initViewsWithColumns();
    this.loadRegion();
  };

  ManageReportRegionController.prototype.changeViewColumns = function() {
    this.setViewColumns();
    this.resetColumnsSelection();
  };

  ManageReportRegionController.prototype.setViewColumns = function() {
    var view = this.$scope.viewsWithColumns.filter(function (view) {
      return view.name === this.$scope.region.view;
    }.bind(this));
    if (view.length > 0) {
      this.$scope.viewColumns = view[0].columns;    
    }
  };

  ManageReportRegionController.prototype.resetColumnsSelection = function() {
    this.$scope.region.reportColumns.forEach(function(reportColumn) {
      if (reportColumn.type === 'COLUMN') {
        reportColumn.column = '';
      }
    });
  };

  ManageReportRegionController.prototype.initRegionTemplates = function() {
    this.templateService.getRegionTemplates().then(function (response) {
      this.$scope.regionTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageReportRegionController.prototype.initReportTemplates = function() {
    this.templateService.getReportTemplates().then(function (response) {
      this.$scope.reportTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageReportRegionController.prototype.initViewsWithColumns = function() {
    this.databaseService.getViewsWithColumns(this.getApplicationId()).then(function (response) {
      this.$scope.viewsWithColumns = response.getDataOrDefault([]);
      this.setViewColumns();
    }.bind(this));
  };

  ManageReportRegionController.prototype.isCreatePage = function() {
    return this.$location.path().endsWith('/create');
  };

  ManageReportRegionController.prototype.isEditPage = function() {
    return this.$location.path().endsWith('/edit');
  };

  ManageReportRegionController.prototype.getDisplayPoint = function() {
    return this.$routeParams.displayPoint || null;
  };
  
  ManageReportRegionController.prototype.getPageId = function() {
    return this.$routeParams.pageId || null;
  };
  
  ManageReportRegionController.prototype.getRegionId = function() {
    return this.$routeParams.regionId || null;
  };
  
  ManageReportRegionController.prototype.getApplicationId = function() {
    return this.$routeParams.applicationId || null;
  };

  ManageReportRegionController.prototype.addReportColumn = function(type) {
    this.$scope.region.reportColumns.push({'type': type, 'isTextEscaped': true});
  };

  ManageReportRegionController.prototype.deleteReportColumn = function(reportColumnPosition) {
    this.$scope.region.reportColumns.splice(reportColumnPosition, 1);
    this.$scope.formError = this.formErrorService.empty();
  };

  ManageReportRegionController.prototype.saveRegion = function() {
    this.regionService.saveReportRegion(
      this.getPageId(),
      this.getDisplayPoint(),
      this.getRegionId(),
      this.$scope.region.name,
      this.$scope.region.sequence,
      this.$scope.region.regionTemplate,
      this.$scope.region.isVisible,
      this.$scope.region.reportTemplate,
      this.$scope.region.view,
      this.$scope.region.showHeader,
      this.$scope.region.itemsPerPage,
      this.$scope.region.paginationQueryParameter,
      this.$scope.region.reportColumns
    ).then(this.handleSaveResponse.bind(this));
  };

  ManageReportRegionController.prototype.handleSaveResponse = function(response) {
    if (!response.hasErrors()) {
      this.$location.path('/application-builder/app/' + this.getApplicationId()
                        + '/pages/' + this.getPageId() + '/regions');
      return;
    } else {
      this.$scope.formError = this.formErrorService.parseApiResponse(response);
    }
  };

  ManageReportRegionController.prototype.loadRegion = function() {
    if (!this.isEditPage()) { return; }
    this.regionService.getReportRegion(this.getRegionId()).then(function (response) {
      this.$scope.region = response.getDataOrDefault({});
      this.setViewColumns();
    }.bind(this));
  };

  function init() {
    module.controller('pgApexApp.region.ManageReportRegionController',
      ['$scope', '$location', '$routeParams', 'regionService',
      'templateService', 'databaseService', 'formErrorService', ManageReportRegionController]);
  }

  init();
})(window);