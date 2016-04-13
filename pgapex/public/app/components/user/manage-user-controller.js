'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.user');

  function ManageUserController($scope, $location, $routeParams, userService, formErrorService) {
    this.$scope = $scope;
    this.$location = $location;
    this.$routeParams = $routeParams;
    this.userService = userService;
    this.formErrorService = formErrorService;

    this.init();
  }

  ManageUserController.prototype.init = function() {
    this.$scope.mode = this.isCreatePage() ? 'create' : 'edit';
    this.$scope.user = {};
    this.$scope.formError = this.formErrorService.empty();
    this.$scope.passwordFieldType = 'password';

    this.$scope.togglePasswordFieldType = this.togglePasswordFieldType.bind(this);
    this.$scope.saveUser = this.saveUser.bind(this);

    this.loadUser();
  };

  ManageUserController.prototype.togglePasswordFieldType = function() {
    this.$scope.passwordFieldType = (this.$scope.passwordFieldType == 'text') ? 'password' : 'text';
  };

  ManageUserController.prototype.isCreatePage = function() {
    return this.$location.path().endsWith('/create');
  };

  ManageUserController.prototype.isEditPage = function() {
    return this.$location.path().endsWith('/edit');
  };

  ManageUserController.prototype.getUserId = function() {
    return this.$routeParams.userId || null;
  };

  ManageUserController.prototype.loadUser = function() {
    if (!this.isEditPage()) { return; }
    this.userService.getUser(this.getUserId()).then(function (response) {
      this.$scope.user = response.getDataOrDefault({});
    }.bind(this));
  };

  ManageUserController.prototype.saveUser = function() {
    this.userService.saveUser(
      this.getUserId(),
      this.$scope.user.username,
      this.$scope.user.password || null,
      this.$scope.user.forename,
      this.$scope.user.surname,
      this.$scope.user.isActive,
      this.$scope.user.isAdministrator
    ).then(this.handleSaveResponse.bind(this));
  };

  ManageUserController.prototype.handleSaveResponse = function(response) {
    if (!response.hasErrors()) {
      this.$location.path('/administration/users');
      return;
    } else {
      this.$scope.formError = this.formErrorService.parseApiResponse(response);
    }
  };

  function init() {
    module.controller('pgApexApp.user.ManageUserController',
      ['$scope', '$location', '$routeParams', 'userService', 'formErrorService', ManageUserController]);
  }

  init();
})(window);