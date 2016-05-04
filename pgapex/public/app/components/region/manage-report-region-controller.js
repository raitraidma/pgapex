'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.page');

  function ManageReportRegionController($scope, $location, $routeParams, regionService,
                                        templateService, databaseService, formErrorService, helperService) {
    this.$scope = $scope;
    this.$scope.helper = helperService;
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

    this.$scope.trackView = function(view) {
      if (!view || !view.attributes) { return view; }
      return view.attributes.schema + '.' + view.attributes.name;
    }.bind(this);

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
    if (!this.$scope.region.view) { return; }
    var view = this.$scope.viewsWithColumns.filter(function (view) {
      return view.attributes.schema === this.$scope.region.view.attributes.schema
          && view.attributes.name === this.$scope.region.view.attributes.name;
    }.bind(this));
    if (view.length > 0) {
      this.$scope.viewColumns = view[0].attributes.columns;
    }
  };

  ManageReportRegionController.prototype.resetColumnsSelection = function() {
    this.$scope.region.reportColumns.forEach(function(reportColumn) {
      if (reportColumn.attributes.type === 'COLUMN') {
        reportColumn.attributes.column = '';
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
    return this.$routeParams.displayPoint ? parseInt(this.$routeParams.displayPoint) : null;
  };
  
  ManageReportRegionController.prototype.getPageId = function() {
    return this.$routeParams.pageId ? parseInt(this.$routeParams.pageId) : null;
  };
  
  ManageReportRegionController.prototype.getRegionId = function() {
    return this.$routeParams.regionId ? parseInt(this.$routeParams.regionId) : null;
  };
  
  ManageReportRegionController.prototype.getApplicationId = function() {
    return this.$routeParams.applicationId ? parseInt(this.$routeParams.applicationId) : null;
  };

  ManageReportRegionController.prototype.addReportColumn = function(type) {
    this.$scope.region.reportColumns.push({'attributes': {'type': type, 'isTextEscaped': true}});
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
      this.$scope.region.isVisible || false,
      this.$scope.region.reportTemplate,
      this.$scope.region.view.attributes.schema,
      this.$scope.region.view.attributes.name,
      this.$scope.region.showHeader || false,
      this.$scope.region.itemsPerPage,
      this.$scope.region.paginationQueryParameter,
      this.getReportColumns()
    ).then(this.handleSaveResponse.bind(this));
  };

  ManageReportRegionController.prototype.getReportColumns = function() {
    return this.$scope.region.reportColumns.map(function(reportColumn) {
      if (reportColumn.attributes.type === 'COLUMN') {
        return {
          'type': 'report-column',
          'attributes': {
            'type': reportColumn.attributes.type,
            'column': reportColumn.attributes.column,
            'heading': reportColumn.attributes.heading,
            'isTextEscaped': reportColumn.attributes.isTextEscaped || false,
            'sequence': reportColumn.attributes.sequence
          }
        }
      } else {
        return {
          'type': 'report-column',
          'attributes': {
            'type': reportColumn.attributes.type,
            'heading': reportColumn.attributes.heading,
            'isTextEscaped': reportColumn.attributes.isTextEscaped || false,
            'sequence': reportColumn.attributes.sequence,
            'linkText': reportColumn.attributes.linkText,
            'linkUrl': reportColumn.attributes.linkUrl,
            'linkAttributes': reportColumn.attributes.linkAttributes || null
          }
        }
      }
    });
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
    this.regionService.getRegion(this.getRegionId()).then(function (response) {
      var region = response.getDataOrDefault({'attributes': {}}).attributes;
      region['view'] = {'attributes': {'schema': region.schemaName, 'name': region.viewName}};
      this.$scope.region = region;
      this.setViewColumns();
    }.bind(this));
  };

  function init() {
    module.controller('pgApexApp.region.ManageReportRegionController',
      ['$scope', '$location', '$routeParams', 'regionService',
      'templateService', 'databaseService', 'formErrorService', 'helperService', ManageReportRegionController]);
  }

  init();
})(window);