'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.page');

  function ManageFormRegionController($scope, $location, $routeParams, regionService,
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

  ManageFormRegionController.prototype.init = function() {
    this.$scope.mode = this.isCreatePage() ? 'create' : 'edit';
    this.$scope.formError = this.formErrorService.empty();
    this.$scope.region = {
      'sequence': 1,
      'functionParameters': [],
      'formPreFillColumns': [],
      'function': {'attributes': {'parameters': []}}
    };
    this.$scope.regionTemplates = [];
    this.$scope.formTemplates = [];
    this.$scope.buttonTemplates = [];
    this.$scope.textInputTemplates = [];
    this.$scope.passwordInputTemplates = [];
    this.$scope.radioInputTemplates = [];
    this.$scope.checkboxInputTemplates = [];
    this.$scope.textareaTemplates = [];
    this.$scope.dropDownTemplates = [];
    this.$scope.viewsWithColumns = [];
    this.$scope.functionsWithParameters = [];
    this.$scope.region.formPreFillColumns = [];
    
    this.$scope.changeFunctionParameters = this.changeFunctionParameters.bind(this);
    this.$scope.changeFormPreFillColumns = this.changeFormPreFillColumns.bind(this);
    this.$scope.atLeastOneFormPreFillColumnHasValue = this.atLeastOneFormPreFillColumnHasValue.bind(this);

    this.$scope.trackDatabaseObject = function(databaseObject) {
      if (!databaseObject || !databaseObject.attributes) { return databaseObject; }
      return databaseObject.attributes.schema + '.' + databaseObject.attributes.name;
    };

    this.$scope.getFunctionParameterTemplates = function(functionParameter) {
      if (!functionParameter || !functionParameter.fieldType) { return []; }
      if (functionParameter.fieldType === 'TEXT') { return this.$scope.textInputTemplates; }
      if (functionParameter.fieldType === 'PASSWORD') { return this.$scope.passwordInputTemplates; }
      if (functionParameter.fieldType === 'CHECKBOX') { return this.$scope.checkboxInputTemplates; }
      if (functionParameter.fieldType === 'RADIO') { return this.$scope.radioInputTemplates; }
      if (functionParameter.fieldType === 'TEXTAREA') { return this.$scope.textareaTemplates; }
      if (functionParameter.fieldType === 'DROP_DOWN') { return this.$scope.dropDownTemplates; }
      return [];
    }.bind(this);

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
    this.templateService.getTextInputTemplates().then(function (response) {
      this.$scope.textInputTemplates = response.getDataOrDefault([]);
    }.bind(this));
    this.templateService.getPasswordInputTemplates().then(function (response) {
      this.$scope.passwordInputTemplates = response.getDataOrDefault([]);
    }.bind(this));
    this.templateService.getRadioInputTemplates().then(function (response) {
      this.$scope.radioInputTemplates = response.getDataOrDefault([]);
    }.bind(this));
    this.templateService.getCheckboxInputTemplates().then(function (response) {
      this.$scope.checkboxInputTemplates = response.getDataOrDefault([]);
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
      functionsWithParameters.forEach(function (functionWithParameters) {
        functionWithParameters.attributes.parameters.sort(function(firstParameter, secondParameter) {
          firstParameter.attributes.ordinalPosition - secondParameter.attributes.ordinalPosition;
        });
      });
      functionsWithParameters.forEach(function(functionWithParameters) {
        this.addDisplayTextToFunction(functionWithParameters);
      }.bind(this));
      this.$scope.functionsWithParameters = functionsWithParameters;
    }.bind(this));
  };

  ManageFormRegionController.prototype.addDisplayTextToFunction = function(functionWithParameters) {
    var displayText = functionWithParameters.attributes.schema;
    displayText += '.';
    displayText += functionWithParameters.attributes.name;
    displayText += '(';
    displayText += functionWithParameters.attributes.parameters.map(function(parameter) {
      return [parameter.attributes.name, parameter.attributes.argumentType].join(' ');
    }).join(', ');
    displayText += ')';
    functionWithParameters.attributes.displayText = displayText;
  };

  ManageFormRegionController.prototype.changeFunctionParameters = function() {
    this.$scope.region.functionParameters = this.$scope.region.function.attributes.parameters;
  };

  ManageFormRegionController.prototype.changeFormPreFillColumns = function() {
    var view = this.$scope.region.formPreFillView;
    this.$scope.region.formPreFillColumns = [];
    if (view.attributes.columns) {
      view.attributes.columns.forEach(function(column) {
        this.$scope.region.formPreFillColumns.push({'column': column, 'value': ''});
      }.bind(this));
    }
  };

  ManageFormRegionController.prototype.atLeastOneFormPreFillColumnHasValue = function() {
    var columns = this.$scope.region.formPreFillColumns;
    if (columns === null) {
      return false;
    }
    for(var i = 0; i < columns.length; i++) {
      if (columns[i].value !== null && columns[i].value.trim() !== '') {
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
    return this.$routeParams.displayPoint ? this.$routeParams.displayPoint : null;
  };
  
  ManageFormRegionController.prototype.getPageId = function() {
    return this.$routeParams.pageId ? this.$routeParams.pageId : null;
  };
  
  ManageFormRegionController.prototype.getRegionId = function() {
    return this.$routeParams.regionId ? this.$routeParams.regionId : null;
  };
  
  ManageFormRegionController.prototype.getApplicationId = function() {
    return this.$routeParams.applicationId ? this.$routeParams.applicationId : null;
  };

  ManageFormRegionController.prototype.saveRegion = function() {
    this.regionService.saveFormRegion(
      this.getPageId(),
      this.getDisplayPoint(),
      this.getRegionId(),
      this.$scope.region.name,
      this.$scope.region.sequence,
      this.$scope.region.regionTemplate,
      this.$scope.region.isVisible || false,
      this.$scope.region.formTemplate,
      this.$scope.region.buttonTemplate,
      this.$scope.region.buttonLabel,
      this.$scope.region.successMessage || null,
      this.$scope.region.errorMessage || null,
      this.$scope.region.redirectUrl || null,
      this.$scope.region.function.attributes.schema,
      this.$scope.region.function.attributes.name,
      this.$scope.region.formPreFill || false,
      this.getFormFields(),
      this.getPreFill()
    ).then(this.handleSaveResponse.bind(this));
  };

  ManageFormRegionController.prototype.getFormFields = function() {
    return this.$scope.region.functionParameters.map(function (functionParameter) {
      return {
        "type": "form-field",
        "attributes": {
          "fieldType": functionParameter.fieldType,
          "fieldTemplate": parseInt(functionParameter.fieldTemplate),
          "label": functionParameter.label,
          "inputName": functionParameter.inputName,
          "sequence": parseInt(functionParameter.sequence),
          "isMandatory": functionParameter.isMandatory || false,
          "isVisible": functionParameter.isVisible || false,
          "defaultValue": functionParameter.defaultValue || null,
          "helpText": functionParameter.helpText || null,
          "functionParameterType": functionParameter.attributes.argumentType,
          "functionParameterOrdinalPosition": functionParameter.attributes.ordinalPosition,
          "preFillColumn": functionParameter.preFillColumn || null,
          "listOfValuesSchema": (functionParameter.listOfValuesView) ? functionParameter.listOfValuesView.attributes.schema : null,
          "listOfValuesView": (functionParameter.listOfValuesView) ? functionParameter.listOfValuesView.attributes.name : null,
          "listOfValuesValue": (functionParameter.listOfValuesValue) ? functionParameter.listOfValuesValue.attributes.name : null,
          "listOfValuesLabel": (functionParameter.listOfValuesLabel) ? functionParameter.listOfValuesLabel.attributes.name : null
        }
      };
    });
  };

  ManageFormRegionController.prototype.getPreFill = function() {
    if (!this.$scope.region.formPreFill) {
      return null;
    }
    return {
      "type": "pre-fill",
      "attributes": {
        "schemaName": this.$scope.region.formPreFillView.attributes.schema,
        "viewName": this.$scope.region.formPreFillView.attributes.name,
        "conditions": this.$scope.region.formPreFillColumns.map(function(condition) {
          return {
            "columnName": condition.column.attributes.name,
            "value": condition.value || null
          }
        })
      }
    }
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
    this.regionService.getRegion(this.getRegionId()).then(function (response) {
      this.$scope.region = response.getDataOrDefault({'attributes': {}}).attributes;
    }.bind(this));
  };

  function init() {
    module.controller('pgApexApp.region.ManageFormRegionController',
      ['$scope', '$location', '$routeParams', 'regionService',
      'templateService', 'databaseService', 'formErrorService', 'helperService', ManageFormRegionController]);
  }

  init();
})(window);