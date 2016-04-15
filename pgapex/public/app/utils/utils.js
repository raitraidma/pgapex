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

if (!String.prototype.repeat) {
  String.prototype.repeat = function(count) {
    if (this == null) {
      throw new TypeError('can\'t convert ' + this + ' to object');
    }    
    if (count < 0) {
      throw new RangeError('repeat count must be non-negative');
    }
    if (count == Infinity) {
      throw new RangeError('repeat count must be less than infinity');
    }

    var str = '' + this;
    var result = '';

    for (var i = 0; i < count; i++) {
      result += str;
    }

    return result;
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
