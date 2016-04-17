'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function DatabaseService(apiService) {
    this.apiService = apiService;
  }

  DatabaseService.prototype.getDatabases = function () {
    return this.apiService.get('api/database/databases.json');
  };

  DatabaseService.prototype.getAuthenticationFunctions = function () {
    return this.apiService.get('api/database/boolean-functions-with-two-string-parameters.json');
  };

  DatabaseService.prototype.getViewsWithColumns = function () {
    return this.apiService.get('api/database/views-with-columns.json');
  };

  // Deprecated
  DatabaseService.prototype.getBooleanFunctions = function () {
    return this.apiService.get('api/database/boolean-functions.json');
  };

  function init() {
    module.service('databaseService', ['apiService', DatabaseService]);
  }

  init();
})(window);