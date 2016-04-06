describe("form-error-service", function() {
  var formErrorService;

  beforeEach(module('pgApexApp'));

  beforeEach(inject(function(_formErrorService_){
    formErrorService = _formErrorService_;
  }));

  describe("FormErrorService", function() {
    it("should pass null data when calling empty", function() {
      expect(formErrorService.empty().apiResponse).toBeNull();
    });
  });

  describe("FormError", function() {
    var fromError;
    beforeEach(function() {
      fromError = formErrorService.empty();
    });

    describe("hasErrors", function() {
      it("should return true when errors exist for given field", function() {
        fromError.errors.field1 = [];
        expect(fromError.hasErrors("field1")).toBe(true);
      });

      it("should return false when errors are missing for given field", function() {
        expect(fromError.hasErrors("field1")).toBe(false);
      });
    });

    describe("getErrors", function() {
      it("should return errors when errors exist for given field", function() {
        fromError.errors.field1 = "errors";
        spyOn(fromError, "hasErrors").and.returnValue(true);
        expect(fromError.getErrors("field1")).toEqual("errors");
      });

      it("should return an empty array when errors are missing for given field", function() {
        spyOn(fromError, "hasErrors").and.returnValue(false);
        expect(fromError.getErrors("field1")).toEqual([]);
      });
    });

    describe("showErrors", function() {
      it("should return true when form field has been touched and field has invalid value", function() {
        spyOn(fromError, "hasErrors").and.returnValue(false);
        expect(fromError.showErrors({"$touched": true, "$invalid": true})).toBe(true);
      });

      it("should return true when field has errors", function() {
        spyOn(fromError, "hasErrors").and.returnValue(true);
        expect(fromError.showErrors({"$touched": false, "$invalid": false})).toBe(true);
      });

      it("should return false when field contains correct data", function() {
        spyOn(fromError, "hasErrors").and.returnValue(false);
        expect(fromError.showErrors({"$touched": true, "$invalid": false})).toBe(false);
      });

      it("should return false when field has not been touched and errors are missing", function() {
        spyOn(fromError, "hasErrors").and.returnValue(false);
        expect(fromError.showErrors({"$touched": false, "$invalid": true})).toBe(false);
      });
    });

    describe("parseApiResponse", function() {
      beforeEach(function() {
        fromError.apiResponse = {
          "hasErrors": function() {},
          "getPointers": function() {},
          "getErrorDetailsWhereSourcePointerIs": function() {}
        };
      });

      it("should parse no errors when pointers are missing in api response", function() {
        spyOn(fromError.apiResponse, "getPointers").and.returnValue([]);
        fromError.parseApiResponse();
        expect(fromError.errors).toEqual({});
      });

      it("should parse errors when pointers exist in api response", function() {
        spyOn(fromError.apiResponse, "getPointers").and.returnValue([
          "data/attribute/p1",
          "data/attribute/p2"
        ]);
        spyOn(fromError.apiResponse, "getErrorDetailsWhereSourcePointerIs").and.callFake(function(pointer) {
          if (pointer == "data/attribute/p1") {return "error-1"; }
          if (pointer == "data/attribute/p2") {return "error-2"; }
        });
        spyOn(fromError.apiResponse, "hasErrors").and.returnValue(true);

        fromError.parseApiResponse();
        expect(fromError.errors.p1).toEqual("error-1");
        expect(fromError.errors.p2).toEqual("error-2");
      });
    });
  });
});