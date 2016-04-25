describe("application-service", function() {
  var applicationService;

  beforeEach(module('pgApexApp'));

  beforeEach(inject(function(_applicationService_){
    applicationService = _applicationService_;
    applicationService.apiService = {
      "get": function() {},
      "post": function() {},
      "createApiRequest": function() { }
    };
  }));

  it("should pass on ID when calling getApplication", function() {
    spyOn(applicationService.apiService, "get");
    applicationService.getApplication(123);
    expect(applicationService.apiService.get).toHaveBeenCalledWith('application/applications/123');
  });

  it("should pass on application data when calling saveApplication", function() {
    var apiRequest = {
      "setAttributes": function() {},
      "getRequest": function() { return "request-data" }
    };
    spyOn(apiRequest, "setAttributes").and.returnValue(apiRequest);
    spyOn(applicationService.apiService, "post");
    spyOn(applicationService.apiService, "createApiRequest").and.returnValue(apiRequest);
    applicationService.saveApplication(123, "app-name", "app-alias", "app-database", "user", "pass");
    expect(applicationService.apiService.post).toHaveBeenCalledWith(jasmine.any(String), "request-data");
    expect(apiRequest.setAttributes).toHaveBeenCalledWith({
      "id" : 123,
      "name" : "app-name",
      "alias": "app-alias",
      "database": "app-database",
      "databaseUsername": "user",
      "databasePassword": "pass"
    });
  });
});