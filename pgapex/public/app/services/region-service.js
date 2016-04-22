'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function RegionService(apiService) {
    this.apiService = apiService;
  }

  RegionService.prototype.getDisplayPointsWithRegions = function (pageId) {
    return this.apiService.get('api/region/display-points-with-regions.json', {"pageId": pageId});
  };

  RegionService.prototype.getHtmlRegion = function (regionId) {
    return this.apiService.get('api/region/html-region.json', {"regionId": regionId});
  };

  RegionService.prototype.getNavigationRegion = function (regionId) {
    return this.apiService.get('api/region/navigation-region.json', {"regionId": regionId});
  };

  RegionService.prototype.getReportRegion = function (regionId) {
    return this.apiService.get('api/region/report-region.json', {"regionId": regionId});
  };

  RegionService.prototype.getFormRegion = function (regionId) {
    return this.apiService.get('api/region/form-region.json', {"regionId": regionId});
  };

  RegionService.prototype.deleteRegion = function (regionId) {
    return this.apiService.post('api/region/delete-region.json', {"regionId": regionId});
  };

  RegionService.prototype.sortDisplayPointsWithRegions = function(displayPointsWithRegions) {
    displayPointsWithRegions.forEach(function(displayPoint) {
      displayPoint.regions = displayPoint.regions.sort(function(firstItem, secondItem) {
        return firstItem.sequence - secondItem.sequence;
      });
    });
  };

  RegionService.prototype.saveHtmlRegion = function (pageId, displayPoint, regionId, name, sequence, regionTemplate, isVisible, content) {
    var postData = {
      "pageId": pageId,
      "displayPoint": displayPoint,
      "regionId": regionId,
      "name": name,
      "sequence": sequence,
      "regionTemplate": regionTemplate,
      "isVisible": isVisible,
      "content": content
    };
    if (name === 'fail') {
      return this.apiService.post('api/region/save-html-region-fail.json', postData);
    }
    return this.apiService.post('api/region/save-html-region-ok.json', postData);
  };

  RegionService.prototype.saveNavigationRegion = function (pageId, displayPoint, regionId, name, sequence, regionTemplate, isVisible,
                                                          navigationTemplate, navigationType, navigation, repeatLastLevel) {
    var postData = {
      "pageId": pageId,
      "displayPoint": displayPoint,
      "regionId": regionId,
      "name": name,
      "sequence": sequence,
      "regionTemplate": regionTemplate,
      "isVisible": isVisible,
      "navigationTemplate": navigationTemplate,
      "navigationType": navigationType,
      "navigation": navigation,
      "repeatLastLevel": repeatLastLevel
    };
    if (name === 'fail') {
      return this.apiService.post('api/region/save-navigation-region-fail.json', postData);
    }
    return this.apiService.post('api/region/save-navigation-region-ok.json', postData);
  };

  RegionService.prototype.saveReportRegion = function (pageId, displayPoint, regionId, name, sequence, regionTemplate, isVisible,
                                                        reportTemplate, view, showHeader, itemsPerPage,
                                                        paginationQueryParameter, reportColumns) {
    var postData = {
      "pageId": pageId,
      "displayPoint": displayPoint,
      "regionId": regionId,
      "name": name,
      "sequence": sequence,
      "regionTemplate": regionTemplate,
      "isVisible": isVisible,
      "reportTemplate": reportTemplate,
      "view": view,
      "showHeader": showHeader,
      "itemsPerPage": itemsPerPage,
      "paginationQueryParameter": paginationQueryParameter,
      "reportColumns": reportColumns
    };
    if (name === 'fail') {
      return this.apiService.post('api/region/save-report-region-fail.json', postData);
    }
    return this.apiService.post('api/region/save-report-region-ok.json', postData);
  };

  RegionService.prototype.saveFormRegion = function (pageId, displayPoint, regionId, name, sequence, regionTemplate, isVisible,
                                                        formTemplate, buttonTemplate, buttonLabel, successMessage,
                                                        errorMessage, redirectUrl, func, functionParameters,
                                                        formPreFill, formPreFillView, formPreFillColumns) {
    var postData = {
      "pageId": pageId,
      "displayPoint": displayPoint,
      "regionId": regionId,
      "name": name,
      "sequence": sequence,
      "regionTemplate": regionTemplate,
      "isVisible": isVisible,
      "formTemplate": formTemplate,
      "buttonTemplate": buttonTemplate,
      "buttonLabel": buttonLabel,
      "successMessage": successMessage,
      "errorMessage": errorMessage,
      "redirectUrl": redirectUrl,
      "function": func,
      "functionParameters": functionParameters,
      "formPreFill": formPreFill,
      "formPreFillView": formPreFillView,
      "formPreFillColumns": formPreFillColumns
    };
    if (name === 'fail') {
      return this.apiService.post('api/region/save-form-region-fail.json', postData);
    }
    return this.apiService.post('api/region/save-form-region-ok.json', postData);
  };

  function init() {
    module.service('regionService', ['apiService', RegionService]);
  }

  init();
})(window);