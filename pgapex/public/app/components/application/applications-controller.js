'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.application');

  function ApplicationsController($scope, $window, applicationService, databaseService, helperService) {
    this.$scope = $scope;
    this.$window = $window;
    this.applicationService = applicationService;
    this.databaseService = databaseService;
    this.helperService = helperService;

    $scope.runApplication = this.runApplication.bind(this);
    $scope.refreshDatabaseObjects = this.refreshDatabaseObjects.bind(this);
    $scope.deleteApplication = this.deleteApplication.bind(this);
    $scope.pageChanged = this.selectVisibleApplications.bind(this);
    this.init();
  }

  ApplicationsController.prototype.init = function() {
    this.$scope.itemsPerPage = 10;
    this.$scope.currentPage = 1;
    this.$scope.allApplications = [];
    this.$scope.applications = [];
    this.loadApplications();
  };

  ApplicationsController.prototype.runApplication = function(applicationId) {
    var appRoot = (!!window.pgApexPath) ? window.pgApexPath : '';
    this.$window.open(appRoot + '/app/' + applicationId, '_blank');
  };

  ApplicationsController.prototype.refreshDatabaseObjects = function(applicationId) {
    this.databaseService.refreshDatabaseObjects();
  };

  ApplicationsController.prototype.loadApplications = function() {
    this.applicationService.getApplications().then(function (response) {
      this.$scope.allApplications = response.getDataOrDefault({'attributes':[]});
      this.selectVisibleApplications();
    }.bind(this));
  };

  ApplicationsController.prototype.selectVisibleApplications = function() {
    var start = (this.$scope.currentPage - 1) * this.$scope.itemsPerPage;
    var end = start + this.$scope.itemsPerPage;
    this.$scope.applications = this.$scope.allApplications.slice(start, end);
  };

  ApplicationsController.prototype.deleteApplication = function(applicationId) {
    this.helperService.confirm('application.deleteApplication',
                               'application.areYouSureThatYouWantToDeleteThisApplication',
                               'application.deleteApplication',
                               'application.cancel')
    .result.then(this.sendDeleteRequest(applicationId).bind(this));
  };

  ApplicationsController.prototype.sendDeleteRequest = function(applicationId) {
    return function() {
      return this.applicationService.deleteApplication(applicationId).then(this.loadApplications.bind(this));
    };
  };

  function init() {
    module.controller('pgApexApp.application.ApplicationsController',
      ['$scope', '$window', 'applicationService', 'databaseService', 'helperService', ApplicationsController]);
  }

  init();
})(window);