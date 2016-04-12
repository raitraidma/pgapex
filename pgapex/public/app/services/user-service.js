'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function UserService(apiService) {
    this.apiService = apiService;
  }

  UserService.prototype.getUsers = function () {
    return this.apiService.get('api/user/users.json');
  };

  function init() {
    module.service('userService', ['apiService', UserService]);
  }

  init();
})(window);