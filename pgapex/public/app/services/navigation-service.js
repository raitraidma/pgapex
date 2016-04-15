'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function NavigationService(apiService) {
    this.apiService = apiService;
  }

  NavigationService.prototype.getNavigationItem = function (navigationItemId) {
    return this.apiService.get('api/navigation/navigation-item.json', {"navigationItemId": navigationItemId});
  };

  NavigationService.prototype.getNavigationItems = function (navigationId) {
    return this.apiService.get('api/navigation/navigation-items.json', {"navigationId": navigationId});
  };

  NavigationService.prototype.deleteNavigationItem = function (navigationItemId) {
    return this.apiService.post('api/navigation/delete-navigation-item.json', {"navigationItemId": navigationItemId});
  };

  NavigationService.prototype.getNavigations = function (applicationId) {
    return this.apiService.get('api/navigation/navigations.json', {"applicationId": applicationId});
  };

  NavigationService.prototype.deleteNavigation = function (navigationId) {
    return this.apiService.post('api/navigation/delete-navigation.json', {"navigationId": navigationId});
  };

  NavigationService.prototype.getNavigation = function (navigationId) {
    return this.apiService.get('api/navigation/navigation.json', {"navigationId": navigationId});
  };

  NavigationService.prototype.createStructuralNavigationList = function(navigationItems) {
    var navigationItemsSortedBySequence = navigationItems.sort(function(firstItem, secondItem) {
      return firstItem.sequence - secondItem.sequence;
    });
    var result = [];
    this.createNavigationList(result, navigationItemsSortedBySequence, null, 0);
    return result;
  };

  NavigationService.prototype.createNavigationList = function(result, navigationItems, parentId, level) {
    navigationItems
    .filter(function(item) { return item.parentNavigationItemId == parentId})
    .forEach(function(item) {
      item['level'] = level;
      result.push(item);
      this.createNavigationList(result, navigationItems, item.id, level+1);
    }.bind(this));
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

  NavigationService.prototype.saveNavigationItem = function (navigationId, navigationItemId, name, sequence, parentNavigationItem, page, url) {
    var postData = {
      "navigationId": navigationId,
      "navigationItemId": navigationItemId,
      "name": name,
      "sequence": sequence,
      "parentNavigationItem": parentNavigationItem,
      "page": page,
      "url": url,
    };
    if (name === 'fail') {
      return this.apiService.post('api/navigation/save-navigation-item-fail.json', postData);
    }
    return this.apiService.post('api/navigation/save-navigation-item-ok.json', postData);
  };

  function init() {
    module.service('navigationService', ['apiService', NavigationService]);
  }

  init();
})(window);