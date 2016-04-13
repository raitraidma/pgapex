describe("auth-service", function() {
  var authService;

  beforeEach(module('pgApexApp'));

  beforeEach(inject(function(_authService_){
    authService = _authService_;
    authService.apiService = {
      "post": function() {}
    };
  }));

  it("should pass on username and password when calling login", function() {
    spyOn(authService.apiService, "post");
    authService.login("ws-1", "user", "pass");
    expect(authService.apiService.post).toHaveBeenCalledWith(jasmine.any(String), {
      "workspace" : "ws-1",
      "username" : "user",
      "password" : "pass"
    });
  });
});