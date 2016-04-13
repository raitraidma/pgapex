'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.user');

  function UsersController($scope, userService, helperService) {
    this.$scope = $scope;
    this.userService = userService;
    this.helperService = helperService;

    this.init();
    $scope.deleteUser = this.deleteUser.bind(this);
    $scope.pageChanged = this.selectVisibleUsers.bind(this);
  }

  UsersController.prototype.init = function() {
    this.$scope.itemsPerPage = 10;
    this.$scope.currentPage = 1;
    this.$scope.allUsers = [];
    this.$scope.users = [];
    this.loadUsers();
  };

  UsersController.prototype.init = function() {
    this.$scope.itemsPerPage = 10;
    this.$scope.currentPage = 1;
    this.$scope.allUsers = [];
    this.$scope.users = [];
    this.loadUsers();
  };

  UsersController.prototype.loadUsers = function() {
    this.userService.getUsers().then(function (response) {
      this.$scope.allUsers = response.getDataOrDefault([]);
      this.selectVisibleUsers();
    }.bind(this));
  };

  UsersController.prototype.selectVisibleUsers = function() {
    var start = (this.$scope.currentPage - 1) * this.$scope.itemsPerPage;
    var end = start + this.$scope.itemsPerPage;
    this.$scope.users = this.$scope.allUsers.slice(start, end);
  };

  UsersController.prototype.deleteUser = function(userId) {
    this.helperService.confirm('user.deleteUser',
                               'user.areYouSureThatYouWantToDeleteThisUser',
                               'user.deleteUser',
                               'user.cancel')
    .result.then(this.sendDeleteRequest(userId).bind(this));
  };

  UsersController.prototype.sendDeleteRequest = function(userId) {
    return function() {
      return this.userService.deleteUser(userId).then(this.loadUsers.bind(this));
    };
  };

  function init() {
    module.controller('pgApexApp.user.UsersController',
      ['$scope', 'userService', 'helperService', UsersController]);
  }

  init();
})(window);