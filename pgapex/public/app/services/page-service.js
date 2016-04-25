'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function PageService(apiService) {
    this.apiService = apiService;
  }

  PageService.prototype.getPage = function (pageId) {
    return this.apiService.get('page/page/' + pageId);
  };

  PageService.prototype.getPages = function (applicationId) {
    return this.apiService.get('page/pages/' + applicationId);
  };

  PageService.prototype.deletePage = function (pageId) {
    return this.apiService.post('page/page/' + pageId + '/delete');
  };

  PageService.prototype.savePage =
    function (applicationId, pageId, title, alias, template, isHomepage, isAuthenticationRequired) {
      var attributes = {
        "applicationId": applicationId,
        "pageId": pageId,
        "title": title,
        "alias": alias,
        "template": template,
        "isHomepage": isHomepage,
        "isAuthenticationRequired": isAuthenticationRequired
      };
      var request = this.apiService.createApiRequest()
        .setAttributes(attributes)
        .getRequest();
      return this.apiService.post('page/page/save', request);
  };

  function init() {
    module.service('pageService', ['apiService', PageService]);
  }

  init();
})(window);