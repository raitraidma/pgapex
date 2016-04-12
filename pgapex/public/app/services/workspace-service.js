'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function WorkspaceService(apiService) {
    this.apiService = apiService;
  }

  WorkspaceService.prototype.getWorkspaces = function () {
    return this.apiService.get('api/workspace/workspaces.json');
  };

  WorkspaceService.prototype.saveWorkspace = function (workspaceId, name, schemas, administrators) {
      var postData = {
        "id" : workspaceId,
        "name" : name,
        "schemas": schemas,
        "administrators": administrators
      };
      if (name === 'fail') {
        return this.apiService.post('api/workspace/save-workspace-fail.json', postData);
      }
      return this.apiService.post('api/workspace/save-workspace-ok.json', postData);
  };

  function init() {
    module.service('workspaceService', ['apiService', WorkspaceService]);
  }

  init();
})(window);