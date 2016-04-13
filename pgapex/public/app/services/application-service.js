'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function ApplicationService(apiService) {
    this.apiService = apiService;
  }

  ApplicationService.prototype.getApplications = function () {
    return this.apiService.get('api/application/applications.json');
  };

  ApplicationService.prototype.getSchemas = function () {
    return this.apiService.get('api/application/schemas.json');
  };

  ApplicationService.prototype.getAuthenticationFunctions = function () {
    return this.apiService.get('api/application/authentication-functions.json');
  };

  ApplicationService.prototype.getApplication = function (applicationId) {
    return this.apiService.get('api/application/application.json', {"id": applicationId});
  };

  ApplicationService.prototype.deleteApplication = function (applicationId) {
    return this.apiService.post('api/application/delete-application.json', {"applicationId": applicationId});
  };

  ApplicationService.prototype.saveApplication =
    function (applicationId, name, alias, schema, authenticationScheme, authenticationFunction, developers) {
      var postData = {
        "id" : applicationId,
        "name" : name,
        "alias": alias,
        "schema": schema,
        "authenticationScheme": authenticationScheme,
        "authenticationFunction": authenticationFunction,
        "developers": developers
      };
      if (name === 'fail') {
        return this.apiService.post('api/application/save-application-fail.json', postData);
      }
      return this.apiService.post('api/application/save-application-ok.json', postData);
  };

  function init() {
    module.service('applicationService', ['apiService', ApplicationService]);
  }

  init();
})(window);