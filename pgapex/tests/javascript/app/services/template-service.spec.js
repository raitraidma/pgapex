describe("template-service", function() {
  var templateService;

  beforeEach(module('pgApexApp'));

  beforeEach(inject(function(_templateService_){
    templateService = _templateService_;
    templateService.apiService = {
      "get": function() {}
    };
    spyOn(templateService.apiService, "get");
  }));

  it("should pass on theme ID when calling getTemplates", function() {
    templateService.getTemplates(123);
    expect(templateService.apiService.get).toHaveBeenCalledWith(jasmine.any(String), {"themeId" : 123});
  });

  it("should pass on application ID when calling getThemes", function() {
    templateService.getThemes(123);
    expect(templateService.apiService.get).toHaveBeenCalledWith(jasmine.any(String), {"applicationId" : 123});
  });
});