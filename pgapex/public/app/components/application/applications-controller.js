'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp.application');

  function ApplicationsController($scope, $window, applicationService) {
    $scope.applications = [];

    function init() {
      applicationService.getApplications().then(function (response) {
        $scope.applications = response.getDataOrDefault([]);
      });
    }

    $scope.runApplication = function(applicationId) {
      $window.open('/app/' + applicationId, '_blank');
    };
    
    init();
  }

  function init() {
    module.controller('pgApexApp.application.ApplicationsController',
      ['$scope', '$window', 'applicationService', ApplicationsController]);
  }

  init();
})(window);