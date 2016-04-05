'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function PageService(apiService) {
    this.apiService = apiService;
  }

  PageService.prototype.getPages = function (applicationId) {
    return this.apiService.get('api/page/pages.json');
  };

  function init() {
    module.service('pageService', ['apiService', PageService]);
  }

  init();
})(window);