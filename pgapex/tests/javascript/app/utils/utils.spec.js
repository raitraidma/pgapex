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
});