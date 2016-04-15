'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function NavigationService(apiService) {
    this.apiService = apiService;
  }

  NavigationService.prototype.getNavigations = function (applicationId) {
    return this.apiService.get('api/navigation/navigations.json', {"applicationId": applicationId});
  };

  NavigationService.prototype.deleteNavigation = function (navigationId) {
    return this.apiService.post('api/navigation/delete-navigation.json', {"navigationId": navigationId});
  };

  NavigationService.prototype.getNavigation = function (navigationId) {
    return this.apiService.get('api/navigation/navigation.json', {"navigationId": navigationId});
  };

  NavigationService.prototype.saveNavigation = function (applicationId, navigationId, name) {
    var postData = {
      "applicationId": applicationId,
      "navigationId": navigationId,
      "name": name
    };
    if (name === 'fail') {
      return this.apiService.post('api/navigation/save-navigation-fail.json', postData);
    }
    return this.apiService.post('api/navigation/save-navigation-ok.json', postData);
  };

  function init() {
    module.service('navigationService', ['apiService', NavigationService]);
  }

  init();
})(window);