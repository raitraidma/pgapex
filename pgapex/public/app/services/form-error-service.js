'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function FormErrorService() {
    this.parseApiResponse = function (apiResponse) {
      var formError = new FormError(apiResponse);
      formError.parseApiResponse();
      return formError;
    }

    this.empty = function () {
      return new FormError(null);
    }
  }

  function FormError(apiResponse) {
    this.apiResponse = apiResponse;
    this.errors = {};
    this.pointerPrefix = '/data/attributes/';
  }

  FormError.prototype.parseApiResponse = function() {
    if (this.apiResponse == null || !this.apiResponse.hasErrors()) { return; }
    this.apiResponse.getPointers().forEach(function(pointer) {
      this.errors[pointer] = this.apiResponse.getErrorDetailsWhereSourcePointerIs(pointer);
    }.bind(this));
  };

  FormError.prototype.hasErrors = function(fieldName) {
    var pointer = this.pointerPrefix + fieldName;
    return this.errors.hasOwnProperty(pointer);
  };

  FormError.prototype.getErrors = function(fieldName) {
    var pointer = this.pointerPrefix + fieldName;
    return this.hasErrors(fieldName) ? this.errors[pointer] : [];
  };

  FormError.prototype.showErrors = function(formField, fieldName) {
    return (!!formField && formField.$touched && formField.$invalid) || this.hasErrors(fieldName);
  }

  function init() {
    module.service('formErrorService', [FormErrorService]);
  }

  init();
})(window);