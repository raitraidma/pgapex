if(!String.prototype.startsWith) {
  String.prototype.startsWith = function (searchString) {
    return !this.indexOf(searchString);
  }
}

if(!String.prototype.contains) {
  String.prototype.contains = function (searchString) {
    return this.indexOf(searchString) !== -1;
  }
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
