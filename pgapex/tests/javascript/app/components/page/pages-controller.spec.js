describe("pgApexApp.page.PagesController", function() {
  beforeEach(module("pgApexApp.page"));

  var $controller;

  beforeEach(inject(function(_$controller_){
    $controller = _$controller_;
  }));

  describe("PagesController", function() {
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

      controller = $controller("pgApexApp.page.PagesController", injections);
    }));

    function prepareMockData() {
      response = {
        "getDataOrDefault": function() { return 'page-data'; }
      };

      injections = {
        "$scope": {},
        "$routeParams": {"applicationId": 123},
        "pageService": {"getPages": function() { return promise; }}
      };
    }

    it("should populate $scope.pages with data when data exists", function() {
      deferred.resolve(response);
      $rootScope.$apply(); 
      expect(injections.$scope.pages).toEqual("page-data");
      expect(injections.$scope.routeParams.applicationId).toEqual(123);
    });
  });
});