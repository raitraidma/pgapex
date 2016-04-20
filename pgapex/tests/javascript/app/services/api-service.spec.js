describe("api-service", function() {
  var apiService;

  beforeEach(module('pgApexApp'));

  beforeEach(inject(function(_apiService_){
    apiService = _apiService_;
  }));

  describe("ApiService", function() {
    beforeEach(function() {
      apiService.http = {"get": function() {}, "post": function() {}};
      apiService.q = {"reject": function() {}};
    });

    it("should call bindResultHandling when get is called", function() {
      spyOn(apiService, "bindResultHandling").and.returnValue("result");
      spyOn(apiService, "createGetParams").and.returnValue("get-params");
      spyOn(apiService, "getHeaders").and.returnValue("headers-data");
      spyOn(apiService, "getPath").and.returnValue("path");
      spyOn(apiService.http, "get");

      expect(apiService.get("api/url")).toEqual("result");
      expect(apiService.getPath).toHaveBeenCalledWith("api/url");
      expect(apiService.http.get).toHaveBeenCalledWith("path", {"params": "get-params", "headers": "headers-data"});
    });

    it("should call bindResultHandling when post is called", function() {
      spyOn(apiService, "bindResultHandling").and.returnValue("result");
      spyOn(apiService, "getHeaders").and.returnValue("headers-data");
      spyOn(apiService, "getPath").and.returnValue("path");
      spyOn(apiService.http, "post");

      expect(apiService.post("api/url", {"post": "data"})).toEqual("result");
      expect(apiService.getPath).toHaveBeenCalledWith("api/url");
      expect(apiService.http.post).toHaveBeenCalledWith("path", {"post": "data"}, {"headers": "headers-data"});
    });

    describe("createGetParams", function() {
      it("should merge params with timestamp", function() {
        spyOn(apiService, "getTimestamp").and.returnValue(123456);
        var getParams = apiService.createGetParams({"id": 123, "name": "value", "ts": 666});
        expect(getParams.id).toEqual(123);
        expect(getParams.name).toEqual("value");
        expect(getParams.ts).toEqual(123456);
      });

      it("should allow undefined params", function() {
        spyOn(apiService, "getTimestamp").and.returnValue(123456);
        var getParams = apiService.createGetParams();
        expect(getParams.ts).toEqual(123456);
      });
    });

    describe("bindResultHandling", function() {
      var $rootScope;
      var deferred;
      var promise;

      beforeEach(inject(function($q, _$rootScope_) {
        $rootScope = _$rootScope_;
        deferred = $q.defer();
        promise = deferred.promise;
      }));

      it("should create api response when query is successful", function() {
        spyOn(apiService, "createApiResponse");
        apiService.bindResultHandling(promise);
        deferred.resolve("response");
        $rootScope.$apply();
        expect(apiService.createApiResponse).toHaveBeenCalledWith("response");
      });

      it("should return promise reject when query fails", function() {
        spyOn(apiService, "createApiResponse");
        spyOn(apiService.q, "reject");
        apiService.bindResultHandling(promise);
        deferred.reject("api-service test reason");
        $rootScope.$apply();
        expect(apiService.createApiResponse).not.toHaveBeenCalled();
        expect(apiService.q.reject).toHaveBeenCalledWith("api-service test reason");
      });
    });
  });

  describe("ApiResponse", function() {
    it("should return original response when getResponse() is called", function() {
      var apiResponse = apiService.createApiResponse("initial-response");
      expect(apiResponse.getResponse()).toEqual("initial-response");
    });

    describe("hasErrors", function() {
      it("should return true when errors exist", function() {
        var apiResponse = apiService.createApiResponse({"data" : {"errors" : []}});
        expect(apiResponse.hasErrors()).toBe(true);
      });

      it("should return false when errors are missing", function() {
        var apiResponse = apiService.createApiResponse({"data" : {}});
        expect(apiResponse.hasErrors()).toBe(false);
      });
    });

    describe("hasData", function() {
      it("should return true when data exists", function() {
        var apiResponse = apiService.createApiResponse({"data" : {"data" : []}});
        expect(apiResponse.hasData()).toBe(true);
      });

      it("should return false when data is missing", function() {
        var apiResponse = apiService.createApiResponse({"data" : {}});
        expect(apiResponse.hasData()).toBe(false);
      });
    });

    it("should call getDataOrDefault when getData is called", function() {
      var apiResponse = apiService.createApiResponse({"data" : {}});
      spyOn(apiResponse, 'getDataOrDefault');
      apiResponse.getData();
      expect(apiResponse.getDataOrDefault).toHaveBeenCalledWith(undefined);
    });

    describe("getDataOrDefault", function() {
      it("should return data when data exists", function() {
        var apiResponse = apiService.createApiResponse({"data" : {"data" : "data-value"}});
        spyOn(apiResponse, "hasData").and.returnValue(true);
        expect(apiResponse.getDataOrDefault("default-value")).toEqual("data-value");
      });

      it("should return default value when data is missing", function() {
        var apiResponse = apiService.createApiResponse({"data" : {}});
        spyOn(apiResponse, "hasData").and.returnValue(false);
        expect(apiResponse.getDataOrDefault("default-value")).toEqual("default-value");
      });
    });

    describe("getErrors", function() {
      it("should return errors when errors exist", function() {
        var apiResponse = apiService.createApiResponse({"data" : {"errors" : "errors"}});
        spyOn(apiResponse, "hasErrors").and.returnValue(true);
        expect(apiResponse.getErrors()).toEqual("errors");
      });

      it("should return undefined when errors are missing", function() {
        var apiResponse = apiService.createApiResponse({"data" : {}});
        spyOn(apiResponse, "hasErrors").and.returnValue(false);
        expect(apiResponse.getErrors()).toBeUndefined();
      });
    });

    describe("getErrorDetailsWhereSourcePointerIs", function() {
      it("should return an empty array when errors are missing", function() {
        var apiResponse = apiService.createApiResponse({"data" : {}});
        spyOn(apiResponse, "hasErrors").and.returnValue(false);
        expect(apiResponse.getErrorDetailsWhereSourcePointerIs()).toEqual([]);
      });

      it("should return error details where source.pointer match", function() {
        var apiResponse = apiService.createApiResponse({"data" : {"errors": [
          {"detail": "Error 1", "source": {"pointer": "/data/attributes/sp1"}},
          {"detail": "Error 2", "source": {"pointer": "/data/attributes/sp2"}},
          {"detail": "Error 3", "source": {"pointer": "/data/attributes/sp1"}}
        ]}});
        spyOn(apiResponse, "hasErrors").and.returnValue(true);

        var errorDetails = apiResponse.getErrorDetailsWhereSourcePointerIs("/data/attributes/sp1");
        expect(errorDetails.length).toEqual(2);
        expect(errorDetails[0]).toEqual("Error 1");
        expect(errorDetails[1]).toEqual("Error 3");
      });
    });

    describe("getPointers", function() {
      it("should return an empty array when errors are missing", function() {
        var apiResponse = apiService.createApiResponse({"data" : {}});
        spyOn(apiResponse, "hasErrors").and.returnValue(false);
        expect(apiResponse.getPointers()).toEqual([]);
      });

      it("should return unique list of source.pointers", function() {
        var apiResponse = apiService.createApiResponse({"data" : {"errors": [
          {"detail": "Error 1", "source": {"pointer": "/data/attributes/sp1"}},
          {"detail": "Error 2", "source": {"pointer": "/data/attributes/sp2"}},
          {"detail": "Error 3", "source": {"pointer": "/data/attributes/sp1"}}
        ]}});
        spyOn(apiResponse, "hasErrors").and.returnValue(true);

        var sourcePointers = apiResponse.getPointers();
        expect(sourcePointers.length).toEqual(2);
        expect(sourcePointers[0]).toEqual("/data/attributes/sp1");
        expect(sourcePointers[1]).toEqual("/data/attributes/sp2");
      });
    });
  });
});