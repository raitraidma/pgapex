describe("pgApexApp.workspace.WorkspacesController", function() {
  beforeEach(module("pgApexApp.workspace"));

  var $controller;

  beforeEach(inject(function(_$controller_){
    $controller = _$controller_;
  }));

  describe("WorkspacesController", function() {
    var $rootScope;
    var deferred;
    var promise;

    var injections;
    var controller;
    var response;

    beforeEach(inject(function($q, _$rootScope_) {
      $rootScope = _$rootScope_;
      deferred = $q.defer();
      promise = deferred.promise;

      prepareMockData();

      controller = $controller("pgApexApp.workspace.WorkspacesController", injections);
    }));

    function prepareMockData() {
      response = {
        "getDataOrDefault": function() {}
      };

      injections = {
        "$scope": {},
        "$uibModal": {},
        "workspaceService": {
          "getWorkspaces": function() { return promise; },
          "deleteWorkspace": function() { return promise; }
        },
        "helperService": {
          "confirm": function() {}
        }
      };
    }

    it("should populate $scope.workspaces with data", function() {
      spyOn(response, "getDataOrDefault").and.returnValue("workspace-data");
      deferred.resolve(response);
      $rootScope.$apply();
      expect(injections.$scope.allWorkspaces).toEqual("workspace-data");
    });

    it("should ask confirmation before deleting workspace", function() {
      spyOn(injections.helperService, "confirm").and.returnValue({"result": promise});
      spyOn(injections.workspaceService, "deleteWorkspace").and.returnValue({"then": function() {}});
      spyOn(response, "getDataOrDefault").and.returnValue([]);
      controller.deleteWorkspace(123);
      deferred.resolve(response);
      $rootScope.$apply();
      expect(injections.helperService.confirm).toHaveBeenCalledWith(
        'workspace.deleteWorkspace', 'workspace.areYouSureThatYouWantToDeleteThisWorkspace',
        'workspace.deleteWorkspace', 'workspace.cancel');
      expect(injections.workspaceService.deleteWorkspace).toHaveBeenCalledWith(123);
    });
  });
});