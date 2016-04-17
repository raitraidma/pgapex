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

  TemplateService.prototype.getPageTemplates = function () {
    return this.apiService.get('api/template/page-templates.json');
  };

  TemplateService.prototype.getRegionTemplates = function () {
    return this.apiService.get('api/template/region-templates.json');
  };

  TemplateService.prototype.getNavigationTemplates = function () {
    return this.apiService.get('api/template/navigation-templates.json');
  };

  TemplateService.prototype.getReportTemplates = function () {
    return this.apiService.get('api/template/report-templates.json');
  };

  function init() {
    module.service('templateService', ['apiService', TemplateService]);
  }

  init();
})(window);