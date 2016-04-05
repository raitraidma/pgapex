'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.template');

  function TemplatesController($scope, $routeParams, templateService) {
    var self = this;
    
    this.initScopeVariables($scope);
    $scope.applicationId = $routeParams.applicationId;
    
    templateService.getTemplates($routeParams.themeId).then(function (response) {
      if (response.hasData()) {
        var templates = response.getData();
        $scope.templates = templates;
        $scope.types = self.getUniqueFieldValues(templates, 'type');
      }  
    });
  }

  TemplatesController.prototype.getUniqueFieldValues = function(templates, field) {
    return templates.map(function (template) {
                      return template[field];
                    }).filter(function (value, index, self) {
                      return self.indexOf(value) === index;
                    });
  };

  TemplatesController.prototype.initScopeVariables = function($scope) {
    $scope.typeFilter = '';
    $scope.nameFilter = '';
    $scope.templates =  [];
    $scope.types = [];
  };

  function init() {
    module.controller('pgApexApp.template.TemplatesController', ['$scope', '$routeParams', 'templateService', TemplatesController]);
  }

  init();
})(window);