describe("pgApexApp.auth.LoginController", function() {
  beforeEach(module("pgApexApp.auth"));

  var $controller;

  beforeEach(inject(function(_$controller_){
    $controller = _$controller_;
  }));

  describe("LoginController", function() {
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
      spyOn(injections.$location, "path");

      controller = $controller("pgApexApp.auth.LoginController", injections);
    }));

    function prepareMockData() {
      response = {
        "hasErrors": function() {}
      };

      injections = {
        "$scope": {"auth": {"login": {"username": "user", "password": "pass"}}},
        "$location": {"path": function() {}},
        "authService": {"login": function() { return promise; }},
        "formErrorService": {"empty": function() {}, "parseApiResponse": function() { return "error-response"; }}
      };
    }

    function callLogin() {
      injections.$scope.login();
      deferred.resolve(response);
      $rootScope.$apply(); 
    }

    it("should redirect to home page when no errors appear", function() {
      spyOn(response, "hasErrors").and.returnValue(false);
      callLogin();
      expect(injections.$location.path).toHaveBeenCalledWith("/application-builder/applications");     
    });

    it("should show errors when errors appear", function() {
      spyOn(response, "hasErrors").and.returnValue(true);
      callLogin();
      expect(injections.$location.path).not.toHaveBeenCalled();     
      expect(injections.$scope.formError).toEqual("error-response");     
    });
  });
});