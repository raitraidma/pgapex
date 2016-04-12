describe("pgApexApp.page.CreatePageController", function() {
  beforeEach(module("pgApexApp.page"));

  var $controller;

  beforeEach(inject(function(_$controller_){
    $controller = _$controller_;
  }));

  it("should populate $scope.routeParams with $routeParams", function() {
    var injections = {
      "$scope": {},
      "$routeParams": {"applicationId": 123}
    };
    $controller("pgApexApp.page.PagesController", injections);
    expect(injections.$scope.routeParams.applicationId).toEqual(123);
  });
});