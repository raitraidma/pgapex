'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function TemplateService(apiService) {
    this.apiService = apiService;
  }

  // Deprecated
  TemplateService.prototype.getTemplates = function (themeId) {
    return this.apiService.get('api/template/templates.json', {"themeId" : themeId});
  };

  // Deprecated
  TemplateService.prototype.getThemes = function (applicationId) {
    return this.apiService.get('api/template/themes.json', {"applicationId": applicationId});
  };

  TemplateService.prototype.getLoginTemplates = function () {
    return this.apiService.get('template/login-templates');
  };

  TemplateService.prototype.getPageTemplates = function () {
    return this.apiService.get('template/page-templates');
  };

  TemplateService.prototype.getRegionTemplates = function () {
    return this.apiService.get('template/region-templates');
  };

  TemplateService.prototype.getNavigationTemplates = function () {
    return this.apiService.get('api/template/navigation-templates.json');
  };

  TemplateService.prototype.getReportTemplates = function () {
    return this.apiService.get('api/template/report-templates.json');
  };

  TemplateService.prototype.getFormTemplates = function () {
    return this.apiService.get('api/template/form-templates.json');
  };

  TemplateService.prototype.getButtonTemplates = function () {
    return this.apiService.get('api/template/button-templates.json');
  };


  TemplateService.prototype.getInputTemplates = function () {
    return this.apiService.get('api/template/input-templates.json');
  };


  TemplateService.prototype.getTextareaTemplates = function () {
    return this.apiService.get('api/template/textarea-templates.json');
  };


  TemplateService.prototype.getDropDownTemplates = function () {
    return this.apiService.get('api/template/drop-down-templates.json');
  };

  function init() {
    module.service('templateService', ['apiService', TemplateService]);
  }

  init();
})(window);