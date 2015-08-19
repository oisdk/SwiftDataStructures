public protocol SetType : SequenceType {
  typealias Member
  init()
  init<S : SequenceType where S.Generator.Element == Member>(_ sequence: S)
  mutating func remove(x: Member) -> Member?
  mutating func insert(x: Member)
  func contains(x: Member) -> Bool
}

extension Trie : SetType {}
extension Tree : SetType {}

extension SetType {
  
  /// Return a new SetType with elements that are either in `self` or a finite
  /// sequence but do not occur in both.
  
  public func exclusiveOr<
    S : SequenceType where S.Generator.Element == Member
    >(sequence: S) -> Self {
      var result = self
      result.exclusiveOrInPlace(sequence)
      return result
  }
  
  /// For each element of a finite sequence, remove it from `self` if it is a
  /// common element, otherwise add it to the SetType.
  
  public mutating func exclusiveOrInPlace<
    S : SequenceType where S.Generator.Element == Member
    >(sequence: S) {
      var seen = Self()
      for x in sequence where !seen.contains(x) {
        if case nil = remove(x) { insert(x) }
        seen.insert(x)
      }
  }
  
  /// Return a new set with elements common to `self` and a finite sequence.
  
  public func intersect<
    S : SequenceType where S.Generator.Element == Member
    >(sequence: S) -> Self {
      var result = Self()
      for x in sequence where contains(x) { result.insert(x) }
      return result
  }
  
  /// Remove any members of `self` that aren't also in a finite sequence.
  
  public mutating func intersectInPlace<
    S : SequenceType where S.Generator.Element == Member
    > (sequence: S) {
      self = intersect(sequence)
  }

  /// Returns true if no members in `self` are in a finite sequence.
  
  public func isDisjointWith<
    S : SequenceType where S.Generator.Element == Member
    >(sequence: S) -> Bool {
      return !sequence.contains(contains)
  }
  
  /// Returns true if `self` is a superset of a finite sequence.
  
  public func isSupersetOf<
    S : SequenceType where S.Generator.Element == Member
    >(sequence: S) -> Bool {
      return !sequence.contains { !self.contains($0) }
  }
  
  /// Return a new SetType with elements in `self` that do not occur
  /// in a finite sequence.
  
  public func subtract<
    S : SequenceType where S.Generator.Element == Member
    >(sequence: S) -> Self {
      var result = self
      result.subtractInPlace(sequence)
      return result
  }
  
  /// Remove all members in `self` that occur in a finite sequence.
  
  public mutating func subtractInPlace<
    S : SequenceType where S.Generator.Element == Member
    >(sequence: S) {
      for x in sequence { remove(x) }
  }
  
  /// Return a new SetType with items in both `self` and a finite sequence.
  
  public func union<
    S : SequenceType where S.Generator.Element == Member
    >(sequence: S) -> Self {
      var result = self
      result.unionInPlace(sequence)
      return result
  }
  
  /// Insert the elements of a finite sequence into `self`
  
  public mutating func unionInPlace<
    S : SequenceType where S.Generator.Element == Member
    >(sequence: S) {
      for x in sequence { insert(x) }
  }
}