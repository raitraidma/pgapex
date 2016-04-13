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

  UserService.prototype.deleteUser = function (userId) {
    return this.apiService.post('api/user/delete-user.json', {"userId": userId});
  };

  UserService.prototype.getUser = function (userId) {
    return this.apiService.get('api/user/user.json', {"userId": userId});
  };

  UserService.prototype.saveUser = function (userId, username, password, forename, surname, isActive, isAdministrator) {
      var postData = {
        "id" : userId,
        "username" : username,
        "password" : password,
        "forename" : forename,
        "surname" : surname,
        "isActive" : isActive,
        "isAdministrator" : isAdministrator,
      };
      if (username === 'fail') {
        return this.apiService.post('api/user/save-user-fail.json', postData);
      }
      return this.apiService.post('api/user/save-user-ok.json', postData);
  };

  function init() {
    module.service('userService', ['apiService', UserService]);
  }

  init();
})(window);