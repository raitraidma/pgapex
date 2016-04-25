'use strict';
(function (window) {
  var angular = window.angular;
  var module = angular.module('pgApexApp');

  function ApiService($http, $q) {
    this.http = $http;
    this.q = $q;
  }

  ApiService.prototype.getPath = function(url) {
    if (url.startsWith('api')) {
      // For mock data.
      // TODO: TO BE REMOVED!!!
      return url;
    }
    var path = !!window.pgApexPath ? window.pgApexPath : '';
    path += '/api';
    path += url.startsWith('/') ? '' : '/';
    return path + url;
  };

  ApiService.prototype.createGetParams = function(params) {
    var urlParams = params || {};
    urlParams.ts = this.getTimestamp();
    return urlParams;
  };

  ApiService.prototype.getHeaders = function() {
    return {
      "X-Requested-With": "XMLHttpRequest"
    };
  };

  ApiService.prototype.get = function(url, params) {
    return this.bindResultHandling(this.http.get(this.getPath(url), {
      "params": this.createGetParams(params),
      "headers": this.getHeaders()
    }));
  };

  ApiService.prototype.post = function(url, postData) {
    return this.bindResultHandling(this.http.post(this.getPath(url), postData, {
      "headers": this.getHeaders()
    }));
  };

  ApiService.prototype.getTimestamp = function() {
    return new Date().getTime();
  };

  ApiService.prototype.bindResultHandling = function(request) {
    return request.then(function (response) {
      return this.createApiResponse(response);
    }.bind(this)).catch(function (response) {
      console.log('Request failed', response);
      return this.q.reject(response);
    }.bind(this));
  };

  ApiService.prototype.createApiRequest = function() {
    return new ApiRequest();
  };

  ApiService.prototype.createApiResponse = function(response) {
    return new ApiResponse(response);
  };

  function ApiRequest() {
    this.attributes = {};
    this.id = null;
    this.type = null;
  }

  ApiRequest.prototype.setAttributes = function(attributes) {
    this.attributes = attributes;
    return this;
  };

  ApiRequest.prototype.setId = function(id) {
    this.id = id;
    return this;
  };

  ApiRequest.prototype.setType = function(type) {
    this.type = type;
    return this;
  };

  ApiRequest.prototype.getRequest = function() {
    return {
      'data': {
        'id': this.id,
        'type': this.type,
        'attributes': this.attributes
      }
    };
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
    return this.hasData() && this.response.data.data !== null ? this.response.data.data : defaultValue;
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
      return error.source && error.source.pointer ? error.source.pointer : '';
    }).filter(function(value, index, list) { 
      return list.indexOf(value) === index;
    });
  };

  function init() {
    module.service('apiService', ['$http', '$q', ApiService]);
  }

  init();
})(window);