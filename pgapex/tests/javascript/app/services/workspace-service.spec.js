describe("workspace-service", function() {
  var workspaceService;

  beforeEach(module('pgApexApp'));

  beforeEach(inject(function(_workspaceService_){
    workspaceService = _workspaceService_;
    workspaceService.apiService = {
      "get": function() {},
      "post": function() {}
    };
  }));

  it("should pass on workspace ID when calling getWorkspace", function() {
    spyOn(workspaceService.apiService, "get");
    workspaceService.getWorkspace(123);
    expect(workspaceService.apiService.get).toHaveBeenCalledWith(jasmine.any(String), {"workspaceId" : 123});
  });

  it("should pass on workspace ID when calling deleteWorkspace", function() {
    spyOn(workspaceService.apiService, "post");
    workspaceService.deleteWorkspace(123);
    expect(workspaceService.apiService.post).toHaveBeenCalledWith(jasmine.any(String), {"workspaceId" : 123});
  });

  it("should pass on workspace data when calling saveWorkspace", function() {
    spyOn(workspaceService.apiService, "post");
    workspaceService.saveWorkspace(123, "name", ["schema-1", "schema-2"], [1,3]);
    expect(workspaceService.apiService.post).toHaveBeenCalledWith(jasmine.any(String), {
      "id" : 123,
      "name" : "name",
      "schemas": ["schema-1", "schema-2"],
      "administrators": [1,3]
    });
  });
});