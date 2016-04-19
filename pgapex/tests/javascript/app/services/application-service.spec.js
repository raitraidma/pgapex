describe("application-service", function() {
  var applicationService;

  beforeEach(module('pgApexApp'));

  beforeEach(inject(function(_applicationService_){
    applicationService = _applicationService_;
    applicationService.apiService = {
      "get": function() {},
      "post": function() {}
    };
  }));

  it("should pass on ID when calling getApplication", function() {
    spyOn(applicationService.apiService, "get");
    applicationService.getApplication(123);
    expect(applicationService.apiService.get).toHaveBeenCalledWith(jasmine.any(String), {"id": 123});
  });

  it("should pass on application data when calling saveApplication", function() {
    spyOn(applicationService.apiService, "post");
    applicationService.saveApplication(123, "app-name", "app-alias", "app-database", "auth-scheme", "auth-function",
                                      "login-page-template", "user", "pass");
    expect(applicationService.apiService.post).toHaveBeenCalledWith(jasmine.any(String), {
      "id" : 123,
      "name" : "app-name",
      "alias": "app-alias",
      "database": "app-database",
      "authenticationScheme": "auth-scheme",
      "authenticationFunction": "auth-function",
      "loginPageTemplate": "login-page-template",
      "databaseUsername": "user",
      "databasePassword": "pass"
    });
  });
});