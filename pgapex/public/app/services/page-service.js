'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function PageService(apiService) {
    this.apiService = apiService;
  }

  PageService.prototype.getPage = function (pageId) {
    return this.apiService.get('api/page/page.json', {"pageId": pageId});
  };

  PageService.prototype.getPages = function (applicationId) {
    return this.apiService.get('api/page/pages.json', {"applicationId": applicationId});
  };

  PageService.prototype.deletePage = function (pageId) {
    return this.apiService.post('api/page/delete-page.json', {"pageId": pageId});
  };

  PageService.prototype.savePage = function (pageId, title, alias, template, isHomepage, isAuthenticationPage, pageCondition, pageConditionArguments) {
    var postData = {
      "pageId": pageId,
      "title": title,
      "alias": alias,
      "template": template,
      "isHomepage": isHomepage,
      "isAuthenticationPage": isAuthenticationPage,
      "pageCondition": pageCondition,
      "pageConditionArguments": pageConditionArguments
    };
    if (title === 'fail') {
      return this.apiService.post('api/page/save-page-fail.json', postData);
    }
    return this.apiService.post('api/page/save-page-ok.json', postData);
  };

  function init() {
    module.service('pageService', ['apiService', PageService]);
  }

  init();
})(window);