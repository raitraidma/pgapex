if(!String.prototype.startsWith) {
  String.prototype.startsWith = function (prefix) {
    return !this.indexOf(prefix);
  }
}

if(!String.prototype.contains) {
  String.prototype.contains = function (searchString) {
    return this.indexOf(searchString) !== -1;
  }
}

if(!String.prototype.endsWith) {
  String.prototype.endsWith = function (suffix) {
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
  };
}

if(!Array.prototype.getUniqueObjectFiledValues) {
  Array.prototype.getUniqueObjectFiledValues = function (field) {
    return this.map(function (object) {
                      return object[field];
                    }).filter(function (value, index, self) {
                      return self.indexOf(value) === index;
                    });
  }
}
