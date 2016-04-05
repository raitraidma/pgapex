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