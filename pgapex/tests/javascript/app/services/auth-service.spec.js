describe("auth-service", function() {
  var authService;

  beforeEach(module('pgApexApp'));

  beforeEach(inject(function(_authService_){
    authService = _authService_;
    authService.apiService = {
      "post": function() {},
      "createApiRequest": function() { }
    };
  }));

  it("should pass on username and password when calling login", function() {
    var apiRequest = {
      "setAttributes": function() {},
      "getRequest": function() { return "request-data" }
    };
    spyOn(apiRequest, "setAttributes").and.returnValue(apiRequest);
    spyOn(authService.apiService, "post");
    spyOn(authService.apiService, "createApiRequest").and.returnValue(apiRequest);

    authService.login("user", "pass");
    expect(authService.apiService.post).toHaveBeenCalledWith(jasmine.any(String), "request-data");
    expect(apiRequest.setAttributes).toHaveBeenCalledWith({
      "username" : "user",
      "password" : "pass"
    });
  });
});