describe("pgApexApp.template.ThemesController", function() {
  beforeEach(module("pgApexApp.template"));

  var $controller;

  beforeEach(inject(function(_$controller_){
    $controller = _$controller_;
  }));

  describe("ThemesController", function() {
    var $rootScope;
    var deferred;
    var promise;

    var injections;
    var controller;
    var response;

    beforeEach(inject(function($q, _$rootScope_) {
      $rootScope = _$rootScope_;
      deferred = $q.defer();
      promise = deferred.promise;

      prepareMockData();

      controller = $controller("pgApexApp.template.ThemesController", injections);
    }));

    function prepareMockData() {
      response = {
        "hasData": function() {},
        "getData": function() { return "themes-data"; }
      };

      injections = {
        "$scope": {},
        "$routeParams": {"applicationId": 123},
        "templateService": {"getThemes": function() { return promise; }}
      };
    }

    it("should populate $scope.themes with data when data exists", function() {
      spyOn(response, "hasData").and.returnValue(true);
      deferred.resolve(response);
      $rootScope.$apply(); 
      expect(injections.$scope.themes).toEqual("themes-data");
      expect(injections.$scope.applicationId).toEqual(123);
    });

    it("should populate $scope.themes with an empty array when data is missing", function() {
      spyOn(response, "hasData").and.returnValue(false);
      deferred.resolve(response);
      $rootScope.$apply(); 
      expect(injections.$scope.themes).toEqual([]);
      expect(injections.$scope.applicationId).toEqual(123); 
    });
  });
});