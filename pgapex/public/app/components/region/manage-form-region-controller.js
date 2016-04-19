'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.page');

  function ManageFormRegionController($scope, $location, $routeParams, regionService,
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

  ManageFormRegionController.prototype.init = function() {
    this.$scope.mode = this.isCreatePage() ? 'create' : 'edit';
    this.$scope.formError = this.formErrorService.empty();
    this.$scope.region = {
      'functionParameters': [],
      'formPreFillColumns': []
    };
    this.$scope.regionTemplates = [];
    this.$scope.formTemplates = [];
    this.$scope.buttonTemplates = [];
    this.$scope.inputTemplates = [];
    this.$scope.textareaTemplates = [];
    this.$scope.dropDownTemplates = [];
    this.$scope.viewsWithColumns = [];
    this.$scope.functionsWithParameters = [];
    this.$scope.region.formPreFillColumns = [];
    
    this.$scope.changeFunctionParameters = this.changeFunctionParameters.bind(this);
    this.$scope.changeFormPreFillColumns = this.changeFormPreFillColumns.bind(this);
    this.$scope.atLeastOneFormPreFillColumnHasValue = this.atLeastOneFormPreFillColumnHasValue.bind(this);

    this.$scope.trackFunction = function(func) {
      if (!func) { return func; }
      this.addDisplayTextToFunction(func);
      return func.displayText;
    }.bind(this);

    this.$scope.trackViewWithColumns = function(view) {
      return view && view.name;
    };

    this.$scope.saveRegion = this.saveRegion.bind(this);
    
    this.initRegionTemplates();
    this.initFormTemplates();
    this.initButtonTemplates();
    this.initFunctionsWithParameters();
    this.initInputTemplates();
    this.initTextareaTemplates();
    this.initDropDownTemplates();
    this.initViewsWithColumns();

    this.loadRegion();
  };

  ManageFormRegionController.prototype.initViewsWithColumns = function() {
    this.databaseService.getViewsWithColumns(this.getApplicationId()).then(function (response) {
      this.$scope.viewsWithColumns = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageFormRegionController.prototype.initRegionTemplates = function() {
    this.templateService.getRegionTemplates().then(function (response) {
      this.$scope.regionTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageFormRegionController.prototype.initFormTemplates = function() {
    this.templateService.getFormTemplates().then(function (response) {
      this.$scope.formTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageFormRegionController.prototype.initButtonTemplates = function() {
    this.templateService.getButtonTemplates().then(function (response) {
      this.$scope.buttonTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageFormRegionController.prototype.initInputTemplates = function() {
    this.templateService.getInputTemplates().then(function (response) {
      this.$scope.inputTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageFormRegionController.prototype.initTextareaTemplates = function() {
    this.templateService.getTextareaTemplates().then(function (response) {
      this.$scope.textareaTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageFormRegionController.prototype.initDropDownTemplates = function() {
    this.templateService.getDropDownTemplates().then(function (response) {
      this.$scope.dropDownTemplates = response.getDataOrDefault([]);
    }.bind(this));
  };

  ManageFormRegionController.prototype.initFunctionsWithParameters = function() {
    this.databaseService.getFunctionsWithParameters(this.getApplicationId()).then(function (response) {
      var functionsWithParameters = response.getDataOrDefault([]);
      functionsWithParameters.forEach(function(functionWithParameters) {
        this.addDisplayTextToFunction(functionWithParameters);
      }.bind(this));
      this.$scope.functionsWithParameters = functionsWithParameters;
    }.bind(this));
  };

  ManageFormRegionController.prototype.addDisplayTextToFunction = function(functionWithParameters) {
    var displayText = functionWithParameters.name;
    displayText += '(';
    displayText += functionWithParameters.parameters.map(function(parameter) {
      return [parameter.name, parameter.argumentType].join(' ');
    }).join(', ');
    displayText += ')';
    functionWithParameters.displayText = displayText;
  };

  ManageFormRegionController.prototype.changeFunctionParameters = function() {
    this.$scope.region.functionParameters = [];
    this.$scope.region.function.parameters.forEach(function(parameter) {
      this.$scope.region.functionParameters.push({'parameter': parameter});
    }.bind(this));
  };

  ManageFormRegionController.prototype.changeFormPreFillColumns = function() {
    var view = this.$scope.region.formPreFillView;
    this.$scope.region.formPreFillColumns = [];
    if (view.columns) {
      view.columns.forEach(function(column) {
        this.$scope.region.formPreFillColumns.push({'column': column, 'value': ''});
      }.bind(this));
    }
  };

  ManageFormRegionController.prototype.atLeastOneFormPreFillColumnHasValue = function() {
    var columns = this.$scope.region.formPreFillColumns;
    for(var i = 0; i < columns.length; i++) {
      if (columns[i].value.trim() !== '') {
        return true;
      }
    }
    return false;
  };

  ManageFormRegionController.prototype.isCreatePage = function() {
    return this.$location.path().endsWith('/create');
  };

  ManageFormRegionController.prototype.isEditPage = function() {
    return this.$location.path().endsWith('/edit');
  };

  ManageFormRegionController.prototype.getDisplayPoint = function() {
    return this.$routeParams.displayPoint || null;
  };
  
  ManageFormRegionController.prototype.getPageId = function() {
    return this.$routeParams.pageId || null;
  };
  
  ManageFormRegionController.prototype.getRegionId = function() {
    return this.$routeParams.regionId || null;
  };
  
  ManageFormRegionController.prototype.getApplicationId = function() {
    return this.$routeParams.applicationId || null;
  };

  ManageFormRegionController.prototype.saveRegion = function() {
    this.regionService.saveFormRegion(
      this.getPageId(),
      this.getDisplayPoint(),
      this.getRegionId(),
      this.$scope.region.name,
      this.$scope.region.sequence,
      this.$scope.region.regionTemplate,
      this.$scope.region.formTemplate,
      this.$scope.region.buttonTemplate,
      this.$scope.region.buttonLabel,
      this.$scope.region.successMessage,
      this.$scope.region.errorMessage,
      this.$scope.region.redirectUrl,
      this.$scope.region.function,
      this.$scope.region.functionParameters,
      this.$scope.region.formPreFill,
      this.$scope.region.formPreFillView,
      this.$scope.region.formPreFillColumns
    ).then(this.handleSaveResponse.bind(this));
  };

  ManageFormRegionController.prototype.handleSaveResponse = function(response) {
    if (!response.hasErrors()) {
      this.$location.path('/application-builder/app/' + this.getApplicationId()
                        + '/pages/' + this.getPageId() + '/regions');
      return;
    } else {
      this.$scope.formError = this.formErrorService.parseApiResponse(response);
    }
  };

  ManageFormRegionController.prototype.loadRegion = function() {
    if (!this.isEditPage()) { return; }
    this.regionService.getFormRegion(this.getRegionId()).then(function (response) {
      this.$scope.region = response.getDataOrDefault({});
    }.bind(this));
  };

  function init() {
    module.controller('pgApexApp.region.ManageFormRegionController',
      ['$scope', '$location', '$routeParams', 'regionService',
      'templateService', 'databaseService', 'formErrorService', ManageFormRegionController]);
  }

  init();
})(window);