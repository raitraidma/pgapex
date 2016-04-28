'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function DatabaseService(apiService) {
    this.apiService = apiService;
  }

  DatabaseService.prototype.getDatabases = function () {
    return this.apiService.get('database/databases');
  };

  DatabaseService.prototype.getAuthenticationFunctions = function (applicationId) {
    return this.apiService.get('database/authentication-functions/' + applicationId);
  };

  DatabaseService.prototype.getViewsWithColumns = function (applicationId) {
    return this.apiService.get('database/views/columns/' + applicationId);
  };

  DatabaseService.prototype.getFunctionsWithParameters = function (applicationId) {
    return this.apiService.get('api/database/functions-with-parameters.json', {'applicationId': applicationId});
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