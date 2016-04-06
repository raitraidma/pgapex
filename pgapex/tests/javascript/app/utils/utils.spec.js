describe("utils", function() {
  describe("String.prototype.startsWith", function() {
    it("should return true if string starts with given string", function() {
      expect("abcdef".startsWith("abc")).toBe(true);
    });

    it("should return false if string does not start with given string", function() {
      expect("abcdef".startsWith("bc")).toBe(false);
    });
  });

  describe("String.prototype.contains", function() {
    it("should return true if string contains given string", function() {
      expect("abcdef".contains("bcd")).toBe(true);
    });

    it("should return false if string does not contain given string", function() {
      expect("abcdef".startsWith("xyz")).toBe(false);
    });
  });

  it("should return unique values when calling getUniqueObjectFiledValues on array of objects", function() {
    expect([
      {"key": "value-1", "key2": "do not care"},
      {"key": "value-2", "key2": "do not care"},
      {"key": "value-1", "key2": "do not care"},
      {"key": "value-3", "key2": "do not care"},
    ].getUniqueObjectFiledValues("key")).toEqual(["value-1", "value-2", "value-3"]);
  });
});