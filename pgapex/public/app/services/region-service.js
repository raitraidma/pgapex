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

  RegionService.prototype.saveHtmlRegion = function (pageId, displayPoint, regionId, name, sequence, template, content) {
    var postData = {
      "pageId": pageId,
      "displayPoint": displayPoint,
      "regionId": regionId,
      "name": name,
      "sequence": sequence,
      "template": template,
      "content": content
    };
    if (name === 'fail') {
      return this.apiService.post('api/region/save-html-region-fail.json', postData);
    }
    return this.apiService.post('api/region/save-html-region-ok.json', postData);
  };

  function init() {
    module.service('regionService', ['apiService', RegionService]);
  }

  init();
})(window);