describe("pgApexApp.auth.LogoutController", function() {
  beforeEach(module("pgApexApp.auth"));

  var $controller;

  beforeEach(inject(function(_$controller_){
    $controller = _$controller_;
  }));

  describe("LogoutController", function() {
    var $rootScope;
    var deferred;
    var promise;

    var injections;
    var controller;

    beforeEach(inject(function($q, _$rootScope_) {
      $rootScope = _$rootScope_;
      deferred = $q.defer();
      promise = deferred.promise;

      injections = {
        "$scope": {},
        "$location": {"path": function() {}},
        "authService": {"logout": function() { return promise; }}
      };
      spyOn(injections.$location, "path");
      controller = $controller("pgApexApp.auth.LogoutController", injections);
    }));

    it("should redirect to login page when logout succeeds", function() {
      deferred.resolve("response");
      $rootScope.$apply(); 
      expect(injections.$location.path).toHaveBeenCalledWith("/login");     
    });

    it("should not redirect when logout fails", function() {
      deferred.reject("response");
      $rootScope.$apply(); 
      expect(injections.$location.path).not.toHaveBeenCalled();     
    });
  });
});