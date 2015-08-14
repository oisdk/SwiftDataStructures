/**
An index type for a `Stack` and `StackSlice`.
*/

public struct StackIndex : Equatable, Comparable, RandomAccessIndexType {
  internal let val: Int
  internal init(_ val: Int) { self.val = val }

  /**
  Returns the next consecutive value after `self`.
  
  - Requires: the next value is representable.
  */
  public func successor() -> StackIndex {
    return StackIndex(val.predecessor())
  }

  /**
  Returns the previous consecutive value before self.
  
  - Requires: the previous value is representable.
  */
  public func predecessor() -> StackIndex {
    return StackIndex(val.successor())
  }

  /**
  Return the minimum number of applications of `successor` or `predecessor` required to
  reach `other` from `self`.
  
  - Complexity: O(1).
  */
  public func distanceTo(other: StackIndex) -> Int {
    return val - other.val
  }
  /**
  Return `self` offset by `n` steps.
  
  - Complexity: O(1).
  - Returns: If `n > 0`, the result of applying `successor` to `self` `n` times. If
  `n < 0`, the result of applying `predecessor` to `self` `n` times. Otherwise, `self`.
  */
  public func advancedBy(n: Int) -> StackIndex {
    return StackIndex(val - n)
  }
}

/// :nodoc:
public func == (lhs: StackIndex, rhs: StackIndex) -> Bool {
  return lhs.val == rhs.val
}
/// :nodoc:
public func < (lhs: StackIndex, rhs: StackIndex) -> Bool {
  return lhs.val > rhs.val
}
/// :nodoc:
public func > (lhs: StackIndex, rhs: StackIndex) -> Bool {
  return lhs.val < rhs.val
}