'use strict';
(function (window) {
  let module = window.angular.module('pgApexApp.page');

  function ManageTabularFormRegionController($scope, $location, $routeParams, regionService, templateService,
                                             databaseService, formErrorService, helperService) {
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

  ManageTabularFormRegionController.prototype.init = function() {
    this.$scope.tabularFormAppId = this.getApplicationId();

    this.$scope.region = {
      'showHeader': true,
      'itemsPerPage': 15,
      'tabularFormColumns': [],
      'tabularFormButtons': []
    };

    this.$scope.mode = this.isCreatePage() ? 'create' : 'edit';
    this.$scope.changeViewColumns = this.changeViewColumns.bind(this);
    this.$scope.saveRegion = this.saveRegion.bind(this);
    this.$scope.formError = this.formErrorService.empty();

    this.$scope.trackView = function(view) {
      if (!view || !view.attributes) { return view; }
      return view.attributes.schema + '.' + view.attributes.name;
    }.bind(this);

    this.initRegionTemplates();
    this.initTabularFormTemplates();
    this.initTabularFormButtonTemplates();
    this.initViewsWithColumns();
  };

  ManageTabularFormRegionController.prototype.getApplicationId = function() {
    return this.$routeParams.applicationId ? parseInt(this.$routeParams.applicationId) : null;
  };

  ManageTabularFormRegionController.prototype.isCreatePage = function() {
    return this.$location.path().endsWith('/create');
  };

  ManageTabularFormRegionController.prototype.isEditPage = function() {
    return this.$location.path().endsWith('/edit');
  };

  ManageTabularFormRegionController.prototype.initRegionTemplates = function() {
    this.templateService.getRegionTemplates().then(function (response) {
      this.$scope.regionTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageTabularFormRegionController.prototype.initTabularFormTemplates = function() {
    this.templateService.getTabularFormTemplates().then(function (response) {
      this.$scope.tabularFormTemplates = response.getDataOrDefault([]);

      this.loadRegion();
    }.bind(this));
  };

  ManageTabularFormRegionController.prototype.initTabularFormButtonTemplates = function() {
    this.templateService.getTabularFormButtonTemplates().then(function (response) {
      this.$scope.tabularFormButtonTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageTabularFormRegionController.prototype.initViewsWithColumns = function() {
    this.databaseService.getViewsWithColumns(this.getApplicationId()).then(function (response) {
      this.$scope.viewsWithColumns = response.getDataOrDefault([]);
      this.setViewColumns();
    }.bind(this));
  };

  ManageTabularFormRegionController.prototype.changeViewColumns = function() {
    this.setViewColumns();
    this.resetColumnsSelection();
  };

  ManageTabularFormRegionController.prototype.setViewColumns = function() {
    if (!this.$scope.region.view) { return; }
    const view = this.$scope.viewsWithColumns.filter(function (view) {
      return view.attributes.schema === this.$scope.region.view.attributes.schema &&
        view.attributes.name === this.$scope.region.view.attributes.name;
    }.bind(this));
    if (view.length > 0) {
      this.$scope.viewColumns = view[0].attributes.columns;
    }
  };

  ManageTabularFormRegionController.prototype.resetColumnsSelection = function() {
    this.$scope.region.tabularFormColumns.forEach(function(tabularFormColumns) {
      if (tabularFormColumns.attributes.type === 'COLUMN') {
        tabularFormColumns.attributes.column = '';
      }
    });
  };

  ManageTabularFormRegionController.prototype.getPageId = function() {
    return this.$routeParams.pageId ? parseInt(this.$routeParams.pageId) : null;
  };

  ManageTabularFormRegionController.prototype.getDisplayPoint = function() {
    return this.$routeParams.displayPoint ? parseInt(this.$routeParams.displayPoint) : null;
  };

  ManageTabularFormRegionController.prototype.getRegionId = function() {
    return this.$routeParams.regionId ? parseInt(this.$routeParams.regionId) : null;
  };

  ManageTabularFormRegionController.prototype.getTabularFormColumns = function() {
    return this.$scope.region.tabularFormColumns.map(function(tabularFormColumn) {
      if (tabularFormColumn.attributes.type === 'COLUMN') {
        return {
          'type': 'tabularform-column',
          'attributes': {
            'type': tabularFormColumn.attributes.type,
            'column': tabularFormColumn.attributes.column,
            'heading': tabularFormColumn.attributes.heading,
            'isTextEscaped': tabularFormColumn.attributes.isTextEscaped || false,
            'sequence': tabularFormColumn.attributes.sequence
          }
        };
      } else {
        return {
          'type': 'tabularform-column',
          'attributes': {
            'type': tabularFormColumn.attributes.type,
            'heading': tabularFormColumn.attributes.heading,
            'isTextEscaped': tabularFormColumn.attributes.isTextEscaped || false,
            'sequence': tabularFormColumn.attributes.sequence,
            'linkText': tabularFormColumn.attributes.linkText,
            'linkUrl': tabularFormColumn.attributes.linkUrl,
            'linkAttributes': tabularFormColumn.attributes.linkAttributes || null
          }
        };
      }
    });
  };

  ManageTabularFormRegionController.prototype.getTabularFormButtons = function() {
    return this.$scope.region.tabularFormButtons.map(function (tabularFormButton) {
      return {
        'templateId': tabularFormButton.buttonTemplateId,
        'sequence': tabularFormButton.sequence,
        'label': tabularFormButton.label,
        'functionName': tabularFormButton.function,
        'successMessage': tabularFormButton.successMessage,
        'errorMessage': tabularFormButton.errorMessage
      };
    });
  };

  ManageTabularFormRegionController.prototype.saveRegion = function() {
    this.regionService.saveTabularFormRegion(
      this.getPageId(),
      this.getDisplayPoint(),
      this.getRegionId(),
      this.$scope.region.regionTemplate,
      this.$scope.region.name,
      this.$scope.region.sequence,
      this.$scope.region.isVisible || false,
      this.$scope.region.tabularFormTemplate,
      this.$scope.region.view.attributes.schema,
      this.$scope.region.view.attributes.name,
      this.$scope.region.showHeader || false,
      this.$scope.region.itemsPerPage,
      this.$scope.region.paginationQueryParameter,
      this.$scope.region.uniqueId,
      this.getTabularFormColumns(),
      this.getTabularFormButtons()
    ).then(this.handleSaveResponse.bind(this));
  };

  ManageTabularFormRegionController.prototype.handleSaveResponse = function(response) {
    if (!response.hasErrors()) {
      this.$location.path('/application-builder/app/' + this.getApplicationId() + '/pages/' + this.getPageId() +
        '/regions');
    } else {
      this.$scope.formError = this.formErrorService.parseApiResponse(response);
    }
  };

  ManageTabularFormRegionController.prototype.loadRegion = function() {
    if (!this.isEditPage()) { return; }
    this.regionService.getRegion(this.getRegionId()).then(function (response) {
      var region = response.getDataOrDefault({'attributes': {}}).attributes;
      region['view'] = {'attributes': {'schema': region.viewSchema, 'name': region.viewName}};
      this.$scope.region = region;
      this.setViewColumns();
    }.bind(this));
  };

  function init() {
    module.controller('pgApexApp.region.ManageTabularFormRegionController',
      ['$scope', '$location', '$routeParams', 'regionService',
        'templateService', 'databaseService', 'formErrorService', ManageTabularFormRegionController]);
  }

  init();
})(window);