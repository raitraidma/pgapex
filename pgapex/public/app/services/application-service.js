'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function ApplicationService(apiService) {
    this.apiService = apiService;
  }

  ApplicationService.prototype.getApplications = function () {
    return this.apiService.get('application/applications');
  };

  ApplicationService.prototype.getApplication = function (applicationId) {
    return this.apiService.get('application/applications/' + applicationId);
  };

  ApplicationService.prototype.getApplicationAuthentication = function (applicationId) {
    return this.apiService.get('application/applications/' + applicationId + '/authentication');
  };

  ApplicationService.prototype.deleteApplication = function (applicationId) {
    return this.apiService.post('application/applications/' + applicationId + '/delete');
  };

  ApplicationService.prototype.saveApplication =
    function (applicationId, name, alias, database, databaseUsername, databasePassword) {
      var attributes = {
        "id" : applicationId,
        "name" : name,
        "alias": alias,
        "database": database,
        "databaseUsername": databaseUsername,
        "databasePassword": databasePassword
      };
      var request = this.apiService.createApiRequest()
        .setAttributes(attributes)
        .getRequest();
      return this.apiService.post('application/save', request);
  };

  ApplicationService.prototype.saveApplicationAuthentication =
    function (applicationId, authenticationScheme, authenticationFunction, loginPageTemplate) {
      var attributes = {
        "id" : applicationId,
        "authenticationScheme" : authenticationScheme,
        "authenticationFunction": authenticationFunction,
        "loginPageTemplate": loginPageTemplate
      };
      var request = this.apiService.createApiRequest()
        .setAttributes(attributes)
        .getRequest();
      return this.apiService.post('application/applications/authentication/save', request);
    };

  function init() {
    module.service('applicationService', ['apiService', ApplicationService]);
  }

  init();
})(window);