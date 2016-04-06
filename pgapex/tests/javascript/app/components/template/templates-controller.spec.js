describe("pgApexApp.template.TemplatesController", function() {
  beforeEach(module("pgApexApp.template"));

  var $controller;

  beforeEach(inject(function(_$controller_){
    $controller = _$controller_;
  }));

  describe("TemplatesController", function() {
    var $rootScope;
    var deferred;
    var promise;

    var injections;
    var controller;
    var response;
    var templates;

    beforeEach(inject(function($q, _$rootScope_) {
      $rootScope = _$rootScope_;
      deferred = $q.defer();
      promise = deferred.promise;

      prepareMockData();

      controller = $controller("pgApexApp.template.TemplatesController", injections);
    }));

    function prepareMockData() {
      templates = {
        "getUniqueObjectFiledValues": function() {
          return "template-types";
        }
      };

      response = {
        "hasData": function() {},
        "getData": function() { return templates; }
      };

      injections = {
        "$scope": {},
        "$routeParams": {"applicationId": 123},
        "templateService": {"getTemplates": function() { return promise; }}
      };
    }

    it("should populate tamplate and type with data", function() {
      spyOn(response, "hasData").and.returnValue(true);
      deferred.resolve(response);
      $rootScope.$apply(); 
      expect(injections.$scope.templates).toEqual(templates);
      expect(injections.$scope.types).toEqual("template-types");
    });
  });
});