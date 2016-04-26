'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function NavigationService(apiService) {
    this.apiService = apiService;
  }

  NavigationService.prototype.getNavigationItem = function (navigationItemId) {
    return this.apiService.get('navigation/navigation/item/' + navigationItemId);
  };

  NavigationService.prototype.getNavigationItems = function (navigationId) {
    return this.apiService.get('navigation/navigation/' + navigationId + '/items');
  };

  NavigationService.prototype.deleteNavigationItem = function (navigationItemId) {
    return this.apiService.post('navigation/navigation/item/' + navigationItemId + '/delete');
  };

  NavigationService.prototype.getNavigations = function (applicationId) {
    return this.apiService.get('navigation/navigations/' + applicationId);
  };

  NavigationService.prototype.deleteNavigation = function (navigationId) {
    return this.apiService.post('navigation/navigation/' + navigationId + '/delete');
  };

  NavigationService.prototype.getNavigation = function (navigationId) {
    return this.apiService.get('navigation/navigation/' + navigationId);
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
    var attributes = {
      "applicationId": applicationId,
      "navigationId": navigationId,
      "name": name
    };
    var request = this.apiService.createApiRequest()
      .setAttributes(attributes)
      .getRequest();
    return this.apiService.post('navigation/navigation/save', request);
  };

  NavigationService.prototype.saveNavigationItem = function (navigationId, navigationItemId, name, sequence, parentNavigationItem, page, url) {
    var attributes = {
      "navigationId": navigationId,
      "navigationItemId": navigationItemId,
      "name": name,
      "sequence": sequence,
      "parentNavigationItem": parentNavigationItem,
      "page": page,
      "url": url,
    };
    var request = this.apiService.createApiRequest()
      .setAttributes(attributes)
      .getRequest();
    return this.apiService.post('navigation/navigation/item/save', request);
  };

  function init() {
    module.service('navigationService', ['apiService', NavigationService]);
  }

  init();
})(window);