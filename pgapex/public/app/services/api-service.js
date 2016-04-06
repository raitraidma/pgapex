'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function ApiService($http, $q) {
    this.http = $http;
    this.q = $q;
  }

  ApiService.prototype.get = function (url, params) {
    return this.bindResultHandling(this.http.get(url, {"params": this.createGetParams(params)}));
  };

  ApiService.prototype.createGetParams = function (params) {
    var urlParams = params || {};
    urlParams.ts = this.getTimestamp();
    return urlParams;
  };

  ApiService.prototype.post = function (url, postData) {
    return this.bindResultHandling(this.http.post(url, postData));
  };

  ApiService.prototype.getTimestamp = function () {
    return new Date().getTime();
  };

  ApiService.prototype.bindResultHandling = function (request) {
    return request.then(function (response) {
      return this.createApiResponse(response);
    }.bind(this)).catch(function (response) {
      console.log('Request failed', response);
      return this.q.reject(response);
    }.bind(this));
  };

  ApiService.prototype.createApiResponse = function (response) {
    return new ApiResponse(response);
  };

  function ApiResponse(response) {
    this.response = response;
  }

  ApiResponse.prototype.getResponse = function() {
    return this.response;
  };

  ApiResponse.prototype.hasErrors = function() {
    return this.response && this.response.data && ('errors' in this.response.data);
  };

  ApiResponse.prototype.hasData = function() {
    return this.response && this.response.data && ('data' in this.response.data);
  };

  ApiResponse.prototype.getData = function() {
    return this.getDataOrDefault(undefined);
  };

  ApiResponse.prototype.getDataOrDefault = function(defaultValue) {
    return this.hasData() ? this.response.data.data : defaultValue;
  };

  ApiResponse.prototype.getErrors = function() {
    return this.hasErrors() ? this.response.data.errors : undefined;
  };

  ApiResponse.prototype.getErrorDetailsWhereSourcePointerIs = function(sourcePointer) {
    if (!this.hasErrors()) { return []; }
    return this.response.data.errors.filter(function (error) {
      return error.source && error.source.pointer && error.source.pointer === sourcePointer;
    }).map(function (error) {
      return error.detail;
    });
  };

  ApiResponse.prototype.getPointers = function() {
    if (!this.hasErrors()) { return []; }
    return this.response.data.errors.map(function(error) {
      return error.source.pointer && error.source.pointer ? error.source.pointer : '';
    }).filter(function(value, index, list) { 
      return list.indexOf(value) === index;
    });
  };

  function init() {
    module.service('apiService', ['$http', '$q', ApiService]);
  }

  init();
})(window);