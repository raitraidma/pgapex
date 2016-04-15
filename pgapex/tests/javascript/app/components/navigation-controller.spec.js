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

    describe("$scope.isNavigationsPage", function() {
      it("should return true when url path begins with /application-builder and contains /navigations", function() {
        prepareTest("/application-builder/xxx/navigations/yyy");
        expect(injections.$scope.isNavigationsPage()).toBe(true);
      });

      it("should return false when url path does not begin with /application-builder", function() {
        prepareTest("/zzz-application-builder/xxx/navigations/yyy");
        expect(injections.$scope.isNavigationsPage()).toBe(false);
      });

      it("should return false when url path does not contain /navigations", function() {
        prepareTest("/application-builder/xxx/");
        expect(injections.$scope.isNavigationsPage()).toBe(false);
      });
    });
  });
});