'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function AuthService(apiService) {
    this.apiService = apiService;
  }

  AuthService.prototype.login = function (workspace, username, password) {
    var postData = {"workspace": workspace, "username" : username, "password": password};
    if (username === 'admin' && password === 'pass') {
      return this.apiService.post('api/auth/login-ok.json', postData);
    }
    return this.apiService.post('api/auth/login-fail.json', postData);
  }

  AuthService.prototype.logout = function () {
    return this.apiService.get('api/auth/logout.json');
  }

  function init() {
    module.service('authService', ['apiService', AuthService]);
  }

  init();
})(window);