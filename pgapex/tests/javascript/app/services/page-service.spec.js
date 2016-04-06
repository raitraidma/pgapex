describe("page-service", function() {
  var pageService;

  beforeEach(module('pgApexApp'));

  beforeEach(inject(function(_pageService_){
    pageService = _pageService_;
    pageService.apiService = {
      "get": function() {}
    };
  }));

  it("should pass on application ID when calling getPages", function() {
    spyOn(pageService.apiService, "get");
    pageService.getPages(123);
    expect(pageService.apiService.get).toHaveBeenCalledWith(jasmine.any(String), {"applicationId" : 123});
  });
});