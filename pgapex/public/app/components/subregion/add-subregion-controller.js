'use strict';
(function (window) {
  let module = window.angular.module('pgApexApp.page');

  function AddSubRegionController($scope, databaseService, regionService) {
    this.$scope = $scope;
    this.databaseService = databaseService;
    this.regionService = regionService;

    this.init();
  }

  AddSubRegionController.prototype.init = function () {
    this.$scope.addSubRegion = this.addSubRegion.bind(this);
    this.$scope.deleteSubRegion = this.deleteSubRegion.bind(this);

    this.initViewsWithColumns();
  };

  AddSubRegionController.prototype.addSubRegion = function (type) {
    this.$scope.lastSequence++;
    this.$scope.subRegions.push({'type': type, 'columns': [], 'view': {'attributes': {}}, 'sequence': this.$scope.lastSequence});
  };

  AddSubRegionController.prototype.deleteSubRegion = function (position) {
    this.$scope.subRegions.splice(position, 1);
  };

  AddSubRegionController.prototype.initViewsWithColumns = function() {
    this.databaseService.getViewsWithColumns(this.$scope.applicationId).then(function (response) {
      this.$scope.viewsWithColumns = response.getDataOrDefault([]);
    }.bind(this));
  };

  function init() {
    module.controller('pgApexApp.region.AddSubRegionController', ['$scope', 'databaseService', 'regionService', AddSubRegionController]);
  }

  init();
})(window);