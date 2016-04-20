'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function AuthService(apiService) {
    this.apiService = apiService;
  }

  AuthService.prototype.login = function (username, password) {
    var attributes = {
      'username': username,
      'password': password
    };
    var request = this.apiService.createApiRequest()
                                .setAttributes(attributes)
                                .getRequest();
    return this.apiService.post('auth/login', request);
  }

  AuthService.prototype.logout = function () {
    return this.apiService.get('auth/logout');
  }

  function init() {
    module.service('authService', ['apiService', AuthService]);
  }

  init();
})(window);