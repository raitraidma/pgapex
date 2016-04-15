describe("NavigationController", function() {
  beforeEach(module("pgApexApp"));

  var $controller;

  beforeEach(inject(function(_$controller_){
    $controller = _$controller_;
  }));

  describe("NavigationController", function() {
    var injections;
    var controller;

    function prepareTest(urlPath) {
        injections = {
          "$scope": {},
          "$location": {"path": function() {}},
          "$routeParams": {"route": "params"}
        };
        spyOn(injections.$location, "path").and.returnValue(urlPath);
        controller = $controller("pgApexApp.NavigationController", injections);
    }

    describe("$scope.isApplicationBuilderPage", function() {
      it("should return true when url path begins with /application-builder", function() {
        prepareTest("/application-builder/xxx");
        expect(injections.$scope.isApplicationBuilderPage()).toBe(true);
      });

      it("should return false when url path does not begin with /application-builder", function() {
        prepareTest("/xxx-application-builder/xxx");
        expect(injections.$scope.isApplicationBuilderPage()).toBe(false);
      });
    });

    describe("$scope.isPagesPage", function() {
      it("should return true when url path begins with /application-builder and contains /pages", function() {
        prepareTest("/application-builder/xxx/pages/yyy");
        expect(injections.$scope.isPagesPage()).toBe(true);
      });

      it("should return false when url path does not begin with /application-builder", function() {
        prepareTest("/zzz-application-builder/xxx/pages/yyy");
        expect(injections.$scope.isPagesPage()).toBe(false);
      });

      it("should return false when url path does not contain /pages", function() {
        prepareTest("/application-builder/xxx/");
        expect(injections.$scope.isPagesPage()).toBe(false);
      });
    });

    describe("$scope.isNavigationPage", function() {
      it("should return true when url path begins with /application-builder and contains /navigation", function() {
        prepareTest("/application-builder/xxx/navigation/yyy");
        expect(injections.$scope.isNavigationPage()).toBe(true);
      });

      it("should return false when url path does not begin with /application-builder", function() {
        prepareTest("/zzz-application-builder/xxx/navigation/yyy");
        expect(injections.$scope.isNavigationPage()).toBe(false);
      });

      it("should return false when url path does not contain /navigation", function() {
        prepareTest("/application-builder/xxx/");
        expect(injections.$scope.isNavigationPage()).toBe(false);
      });
    });
  });
});