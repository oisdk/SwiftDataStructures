/**
Conforming types should have efficient `remove`, `insert`, and `contains` methods.
Conforming types get set-like methods - `union`, etc.
*/

public protocol SetType : SequenceType {
  
  /// Create an empty instance of `self`
  
  init()
  
  /// Create an instance of `self` containing the elements of `sequence`
  
  init<S : SequenceType where S.Generator.Element == Generator.Element>(_ sequence: S)
  
  /// Remove `x` from `self` and return it if it was present. If not, return `nil`.
  
  mutating func remove(x: Generator.Element) -> Generator.Element?
  
  /// Insert `x` into `self`
  
  mutating func insert(x: Generator.Element)
  
  /// returns `true` iff `self` contains `x`
  
  func contains(x: Generator.Element) -> Bool
  
  /// Remove the member if it was present, insert it if it was not.
  
  mutating func XOR(x: Generator.Element)
}

/// :nodoc:

extension SetType {
    
  /// Return a new SetType with elements that are either in `self` or a finite
  /// sequence but do not occur in both.
  
  public func exclusiveOr<
    S : SequenceType where S.Generator.Element == Generator.Element
    >(sequence: S) -> Self {
      var result = self
      result.exclusiveOrInPlace(sequence)
      return result
  }
  
  /// For each element of a finite sequence, remove it from `self` if it is a
  /// common element, otherwise add it to the SetType.
  
  public mutating func exclusiveOrInPlace<
    S : SequenceType where S.Generator.Element == Generator.Element
    >(sequence: S) {
      var seen = Self()
      for x in sequence where !seen.contains(x) {
        XOR(x)
        seen.insert(x)
      }
  }
  
  /// Return a new set with elements common to `self` and a finite sequence.
  
  public func intersect<
    S : SequenceType where S.Generator.Element == Generator.Element
    >(sequence: S) -> Self {
      var result = Self()
      for x in sequence where contains(x) { result.insert(x) }
      return result
  }
  
  /// Remove any elements of `self` that aren't also in a finite sequence.
  
  public mutating func intersectInPlace<
    S : SequenceType where S.Generator.Element == Generator.Element
    > (sequence: S) {
      self = intersect(sequence)
  }

  /// Returns true if no elements in `self` are in a finite sequence.
  
  public func isDisjointWith<
    S : SequenceType where S.Generator.Element == Generator.Element
    >(sequence: S) -> Bool {
      return !sequence.contains(contains)
  }
  
  /// Returns true if `self` is a superset of a finite sequence.
  
  public func isSupersetOf<
    S : SequenceType where S.Generator.Element == Generator.Element
    >(sequence: S) -> Bool {
      return !sequence.contains { !self.contains($0) }
  }
  
  /// Returns true if `self` is a subset of a finite sequence
  
  public func isSubsetOf<
    S : SequenceType where S.Generator.Element == Generator.Element
    >(sequence: S) -> Bool {
      return Self(sequence).isSupersetOf(self)
  }
  
  /// Return a new SetType with elements in `self` that do not occur
  /// in a finite sequence.
  
  public func subtract<
    S : SequenceType where S.Generator.Element == Generator.Element
    >(sequence: S) -> Self {
      var result = self
      for x in sequence { result.remove(x) }
      return result
  }
  
  /// Remove all elements in `self` that occur in a finite sequence.
  
  public mutating func subtractInPlace<
    S : SequenceType where S.Generator.Element == Generator.Element
    >(sequence: S) {
      for x in sequence { remove(x) }
  }
  
  /// Return a new SetType with items in both `self` and a finite sequence.
  
  public func union<
    S : SequenceType where S.Generator.Element == Generator.Element
    >(sequence: S) -> Self {
      var result = self
      for x in sequence { result.insert(x) }
      return result
  }
  
  /// Insert the elements of a finite sequence into `self`
  
  public mutating func unionInPlace<
    S : SequenceType where S.Generator.Element == Generator.Element
    >(sequence: S) {
      for x in sequence { insert(x) }
  }
}